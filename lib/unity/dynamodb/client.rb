# frozen_string_literal: true

module Unity
  module DynamoDB
    class Client
      attr_accessor :retry_on_throughput_exceeded,
                    :max_retries_on_throughput_exceeded,
                    :retry_interval_on_throughput_exceeded,
                    :http_timeouts

      def initialize(options = {})
        @aws_region = options[:region] || ENV['AWS_REGION'] || Aws.shared_config.region
        @aws_credentials = options.delete(:credentials) || init_credentials_provider_chain

        @aws_signer = Aws::Sigv4::Signer.new(
          service: 'dynamodb',
          region: @aws_region,
          credentials_provider: @aws_credentials
        )

        endpoint = options.delete(:endpoint) || "dynamodb.#{@aws_region}.amazonaws.com"
        @endpoint_uri = \
          if endpoint.start_with?('http')
            URI.parse(endpoint)
          else
            URI.parse("https://#{endpoint}")
          end
        @endpoint_url = @endpoint_uri.to_s
        @retry_on_throughput_exceeded = options.delete(:retry_on_throughput_exceeded) || true
        @max_retries_on_throughput_exceeded = options.delete(:max_retries_on_throughput_exceeded) || 3
        @retry_interval_on_throughput_exceeded = options.delete(:retry_interval_on_throughput_exceeded) || 1
        @http_timeouts = options.delete(:http_timeouts) || { connect: 5, write: 5, read: 5 }

        # logger = Logger.new(STDOUT)
        # logger.level = Logger::DEBUG
        # @http = HTTP.use(logging: { logger: logger }).timeout(@http_timeouts).persistent(@endpoint_url)

        @http = HTTP.timeout(@http_timeouts).persistent(
          @endpoint_url,
          timeout: options.delete(:keep_alive_timeout) || 15
        )
      end

      def query(parameters)
        execute(
          parameters,
          Unity::DynamoDB::Shapes::QueryShape,
          Unity::DynamoDB::Outputs::QueryOutput
        )
      end

      def scan(parameters)
        execute(
          parameters,
          Unity::DynamoDB::Shapes::ScanShape,
          Unity::DynamoDB::Outputs::ScanOutput
        )
      end

      def batch_get_item(parameters)
        execute(
          parameters,
          Unity::DynamoDB::Shapes::BatchGetItemShape,
          Unity::DynamoDB::Outputs::BatchGetItemOutput
        )
      end

      def get_item(parameters)
        execute(
          parameters,
          Unity::DynamoDB::Shapes::GetItemShape,
          Unity::DynamoDB::Outputs::GetItemOutput
        )
      end

      def batch_write_item(parameters)
        execute(
          parameters,
          Unity::DynamoDB::Shapes::BatchWriteItemShape,
          Unity::DynamoDB::Outputs::BatchWriteItemOutput
        )
      end

      def put_item(parameters)
        execute(
          parameters,
          Unity::DynamoDB::Shapes::PutItemShape,
          Unity::DynamoDB::Outputs::PutItemOutput
        )
      end

      def delete_item(parameters)
        execute(
          parameters,
          Unity::DynamoDB::Shapes::DeleteItemShape,
          Unity::DynamoDB::Outputs::DeleteItemOutput
        )
      end

      def update_item(parameters)
        execute(
          parameters,
          Unity::DynamoDB::Shapes::UpdateItemShape,
          Unity::DynamoDB::Outputs::UpdateItemOutput
        )
      end

      def transact_get_items(parameters)
        execute(
          parameters,
          Unity::DynamoDB::Shapes::TransactGetItemsShape,
          Unity::DynamoDB::Outputs::TransactGetItemsOutput
        )
      end

      def transact_write_items(parameters)
        execute(
          parameters,
          Unity::DynamoDB::Shapes::TransactWriteItemsShape,
          Unity::DynamoDB::Outputs::TransactWriteItemsOutput
        )
      end

      def list_tables(parameters = {})
        execute(
          parameters,
          Unity::DynamoDB::Shapes::ListTablesShape,
          Unity::DynamoDB::Outputs::ListTablesOutput
        )
      end

      private

      def execute(parameters, shape_klass, output_klass)
        retries_count = 0

        begin
          shape = shape_klass.new(parameters)
          resp = request(shape_klass::API_TARGET, shape)

          output_klass.from_dynamodb_json(resp.parse(:json))
        rescue Unity::DynamoDB::Errors::ProvisionedThroughputExceededError
          raise unless @retry_on_throughput_exceeded == true

          raise if retries_count >= @max_retries_on_throughput_exceeded

          retries_count += 1

          sleep @retry_interval_on_throughput_exceeded
          retry
        end
      end

      def request(amz_target, shape)
        body = shape.to_dynamodb_json
        request_headers = {
          'Content-Length' => body.bytesize,
          'Content-Type' => 'application/x-amz-json-1.0',
          'X-Amz-Target' => amz_target
        }

        signature = @aws_signer.sign_request(
          http_method: 'POST',
          url: @endpoint_url,
          headers: request_headers,
          body: body
        )
        request_headers.merge!(signature.headers)

        resp = @http.post(
          '/',
          headers: request_headers,
          body: body
        ).flush
        handle_error(resp) unless resp.code == 200

        resp
      end

      def handle_error(resp)
        data = resp.parse(:json)

        case data['__type']
        when /ResourceNotFoundException/
          raise Unity::DynamoDB::Errors::ResourceNotFoundError.new(data['message'])
        when /ValidationException/
          raise Unity::DynamoDB::Errors::ValidationError.new(data['message'])
        when /ConditionalCheckFailedException/
          raise Unity::DynamoDB::Errors::ConditionalCheckFailedError.new(data['message'])
        when /ProvisionedThroughputExceededException/
          raise Unity::DynamoDB::Errors::ProvisionedThroughputExceededError.new(data['message'])
        when /RequestLimitExceeded/
          raise Unity::DynamoDB::Errors::RequestLimitExceededError.new(data['message'])
        when /TransactionCanceledException/
          raise Unity::DynamoDB::Errors::TransactionCanceledError.new(data['message'])
        when /SerializationException/
          raise Unity::DynamoDB::Errors::SerializationError.new(data['message'])
        else
          raise Unity::DynamoDB::Errors::UnknownError.new(
            data['__type'], data['message']
          )
        end
      end

      def init_credentials_provider_chain
        Aws::CredentialProviderChain.new(
          OpenStruct.new(
            region: @aws_region,
            instance_profile_credentials_timeout: 1,
            instance_profile_credentials_retries: 1
          )
        ).resolve
      end
    end
  end
end

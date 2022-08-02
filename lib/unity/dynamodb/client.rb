# frozen_string_literal: true

module Unity
  module DynamoDB
    class Client
      def initialize(options = {})
        @aws_region = options[:region] || ENV['AWS_REGION'] || Aws.shared_config.region
        @aws_credentials = Aws::CredentialProviderChain.new(
          OpenStruct.new(
            region: @aws_region,
            instance_profile_credentials_timeout: 1,
            instance_profile_credentials_retries: 0
          )
        ).resolve

        @aws_signer = Aws::Sigv4::Signer.new(
          service: 'dynamodb',
          region: @aws_region,
          credentials_provider: @aws_credentials
        )

        @endpoint = options.delete(:endpoint) || "https://dynamodb.#{@aws_region}.amazonaws.com"
        @endpoint_uri = URI.parse(@endpoint)
        # logger = Logger.new(STDOUT)
        # logger.level = Logger::DEBUG
        # @http = HTTP.use(logging: { logger: logger }).persistent(@endpoint)
        @http = HTTP.persistent(@endpoint)
      end

      def query(parameters)
        shape = Unity::DynamoDB::Shapes::QueryShape.new(parameters)
        resp = request('DynamoDB_20120810.Query', shape)

        Unity::DynamoDB::Outputs::QueryOutput.from_dynamodb_json(
          resp.parse(:json)
        )
      end

      def scan(parameters)
        shape = Unity::DynamoDB::Shapes::ScanShape.new(parameters)
        resp = request('DynamoDB_20120810.Scan', shape)

        Unity::DynamoDB::Outputs::ScanOutput.from_dynamodb_json(
          resp.parse(:json)
        )
      end

      def batch_get_item(parameters)
        shape = Unity::DynamoDB::Shapes::BatchGetItemShape.new(parameters)
        resp = request('DynamoDB_20120810.BatchGetItem', shape)

        Unity::DynamoDB::Outputs::BatchGetItemOutput.from_dynamodb_json(
          resp.parse(:json)
        )
      end

      def get_item(parameters)
        shape = Unity::DynamoDB::Shapes::GetItemShape.new(parameters)
        resp = request('DynamoDB_20120810.GetItem', shape)

        Unity::DynamoDB::Outputs::GetItemOutput.from_dynamodb_json(
          resp.parse(:json)
        )
      end

      def batch_write_item(parameters)
        shape = Unity::DynamoDB::Shapes::BatchWriteItemShape.new(parameters)
        resp = request('DynamoDB_20120810.BatchWriteItem', shape)

        Unity::DynamoDB::Outputs::BatchWriteItemOutput.from_dynamodb_json(
          resp.parse(:json)
        )
      end

      def put_item(parameters)
        shape = Unity::DynamoDB::Shapes::PutItemShape.new(parameters)
        resp = request('DynamoDB_20120810.PutItem', shape)

        Unity::DynamoDB::Outputs::PutItemOutput.from_dynamodb_json(
          resp.parse(:json)
        )
      end

      def delete_item(parameters)
        shape = Unity::DynamoDB::Shapes::DeleteItemShape.new(parameters)
        resp = request('DynamoDB_20120810.DeleteItem', shape)

        Unity::DynamoDB::Outputs::DeleteItemOutput.from_dynamodb_json(
          resp.parse(:json)
        )
      end

      def update_item(parameters)
        shape = Unity::DynamoDB::Shapes::UpdateItemShape.new(parameters)
        resp = request('DynamoDB_20120810.UpdateItem', shape)

        Unity::DynamoDB::Outputs::UpdateItemOutput.from_dynamodb_json(
          resp.parse(:json)
        )
      end

      def transact_get_items(parameters)
        shape = Unity::DynamoDB::Shapes::TransactGetItemsShape.new(parameters)
        resp = request('DynamoDB_20120810.TransactGetItems', shape)

        Unity::DynamoDB::Outputs::TransactGetItemsOutput.from_dynamodb_json(
          resp.parse(:json)
        )
      end

      def transact_write_items(parameters)
        shape = Unity::DynamoDB::Shapes::TransactWriteItemsShape.new(parameters)
        resp = request('DynamoDB_20120810.TransactWriteItems', shape)

        Unity::DynamoDB::Outputs::TransactWriteItemsOutput.from_dynamodb_json(
          resp.parse(:json)
        )
      end

      private

      def request(amz_target, shape)
        body = shape.to_dynamodb_json
        request_headers = {
          'Accept-Encoding' => 'identity',
          'Content-Length' => body.bytesize,
          'User-Agent' => 'unity-dynamodb',
          'Content-Type' => 'application/x-amz-json-1.0',
          'X-Amz-Target' => amz_target
        }
        signature = @aws_signer.sign_request(
          http_method: 'POST',
          url: @endpoint,
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
          raise Unity::DynamoDB::Errors::ValidationError.new(data['message'])
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
        else
          raise Unity::DynamoDB::Errors::UnknownError.new(
            data['__type'], data['message']
          )
        end
      end
    end
  end
end

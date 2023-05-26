# frozen_string_literal: true

module Unity
  module DynamoDB
    module Shapes
      class ExecuteStatementShape
        API_TARGET = 'DynamoDB_20120810.ExecuteStatement'

        def initialize(attributes)
          @consistent_read = attributes[:consistent_read]
          @limit = attributes[:limit]
          @next_token = attributes[:next_token]
          @parameters = attributes[:parameters]
          @return_consumed_capacity = attributes[:return_consumed_capacity]
          @statement = attributes[:statement]
        end

        def as_dynamodb_json
          hash = Unity::DynamoDB::HashNonNull.new
          hash['ConsistentRead'] = @consistent_read
          hash['Limit'] = @limit
          hash['NextToken'] = @next_token
          hash['Parameters'] = parameters_serializer(@parameters) unless @parameters.nil?
          hash['ReturnConsumedCapacity'] = @return_consumed_capacity
          hash['Statement'] = @statement
          hash
        end

        def to_dynamodb_json
          as_dynamodb_json.to_json
        end

        private

        def parameters_serializer(parameters)
          attribute_serializer = Unity::DynamoDB::AttributeSerializer.new

          parameters.map do |item|
            attribute_serializer.translate(item)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Unity
  module DynamoDB
    module Shapes
      class GetItemShape
        def initialize(attributes)
          @table_name = attributes[:table_name]
          @key = attributes[:key]
          @consistent_read = attributes[:consistent_read]
          @projection_expression = attributes[:projection_expression]
          @expression_attribute_names = attributes[:expression_attribute_names]
          @return_consumed_capacity = attributes[:return_consumed_capacity]
        end

        def as_dynamodb_json
          attribute_serializer = Unity::DynamoDB::AttributeSerializer.new

          hash = Unity::DynamoDB::HashNonNull.new
          hash['TableName'] = @table_name
          hash['ConsistentRead'] = @consistent_read
          hash['ProjectionExpression'] = @projection_expression
          hash['ExpressionAttributeNames'] = @expression_attribute_names
          hash['ReturnConsumedCapacity'] = @return_consumed_capacity
          hash['Key'] = attribute_serializer.call(@key)
          hash
        end

        def to_dynamodb_json
          as_dynamodb_json.to_json
        end
      end
    end
  end
end

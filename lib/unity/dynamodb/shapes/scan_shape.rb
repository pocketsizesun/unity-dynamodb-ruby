# frozen_string_literal: true

module Unity
  module DynamoDB
    module Shapes
      class ScanShape
        def initialize(attributes)
          @table_name = attributes[:table_name]
          @index_name = attributes[:index_name]
          @limit = attributes[:limit]
          @consistent_read = attributes[:consistent_read]
          @projection_expression = attributes[:projection_expression]
          @filter_expression = attributes[:filter_expression]
          @expression_attribute_names = attributes[:expression_attribute_names]
          @expression_attribute_values = attributes[:expression_attribute_values]
          @return_consumed_capacity = attributes[:return_consumed_capacity]
          @exclusive_start_key = attributes[:exclusive_start_key]
          @segment = attributes[:segment]
          @select = attributes[:select]
        end

        def as_dynamodb_json
          attribute_serializer = Unity::DynamoDB::AttributeSerializer.new

          hash = Unity::DynamoDB::HashNonNull.new
          hash['TableName'] = @table_name
          hash['IndexName'] = @index_name
          hash['Limit'] = @limit
          hash['ConsistentRead'] = @consistent_read
          hash['ProjectionExpression'] = @projection_expression
          hash['ExpressionAttributeNames'] = @expression_attribute_names
          hash['ExpressionAttributeValues'] = \
            unless @expression_attribute_values.nil?
              attribute_serializer.call(@expression_attribute_values)
            end
          hash['ExclusiveStartKey'] = \
            unless @exclusive_start_key.nil?
              attribute_serializer.call(@exclusive_start_key)
            end
          hash['ReturnConsumedCapacity'] = @return_consumed_capacity
          hash['FilterExpression'] = @filter_expression
          hash['Segment'] = @segment
          hash['Select'] = @select
          hash
        end

        def to_dynamodb_json
          as_dynamodb_json.to_json
        end
      end
    end
  end
end

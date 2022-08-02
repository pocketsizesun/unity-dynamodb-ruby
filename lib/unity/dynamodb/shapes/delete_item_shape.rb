# frozen_string_literal: true

module Unity
  module DynamoDB
    module Shapes
      class DeleteItemShape
        def initialize(attributes)
          @table_name = attributes[:table_name]
          @key = attributes[:key]
          @condition_expression = attributes[:condition_expression]
          @expression_attribute_names = attributes[:expression_attribute_names]
          @expression_attribute_values = attributes[:expression_attribute_values]
          @return_consumed_capacity = attributes[:return_consumed_capacity]
          @return_item_collection_metrics = attributes[:return_item_collection_metrics]
          @return_values = attributes[:return_values]
        end

        def as_dynamodb_json
          attribute_serializer = Unity::DynamoDB::AttributeSerializer.new

          hash = Unity::DynamoDB::HashNonNull.new
          hash['TableName'] = @table_name
          hash['Key'] = attribute_serializer.call(@key)
          hash['ConditionExpression'] = @condition_expression
          hash['ExpressionAttributeNames'] = @expression_attribute_names
          hash['ExpressionAttributeValues'] = \
            unless @expression_attribute_values.nil?
              attribute_serializer.call(@expression_attribute_values)
            end
          hash['ReturnConsumedCapacity'] = @return_consumed_capacity
          hash['ReturnItemCollectionMetrics'] = @return_item_collection_metrics
          hash['ReturnValues'] = @return_values
          hash
        end

        def to_dynamodb_json
          as_dynamodb_json.to_json
        end
      end
    end
  end
end

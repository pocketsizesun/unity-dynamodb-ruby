# frozen_string_literal: true

module Unity
  module DynamoDB
    module Shapes
      class BatchGetItemShape
        def initialize(attributes)
          @request_items = attributes[:request_items]
          @return_consumed_capacity = attributes[:return_consumed_capacity]
        end

        def as_dynamodb_json
          attribute_serializer = Unity::DynamoDB::AttributeSerializer.new

          hash = Unity::DynamoDB::HashNonNull.new
          hash['ReturnConsumedCapacity'] = @return_consumed_capacity
          hash['RequestItems'] = {}
          @request_items.each do |table_name, params|
            sub_hash = Unity::DynamoDB::HashNonNull.new
            sub_hash['ConsistentRead'] = params[:consistent_read]
            sub_hash['ExpressionAttributeNames'] = params[:expression_attribute_names]
            sub_hash['ProjectionExpression'] = params[:projection_expression]
            sub_hash['Keys'] = params[:keys].map do |item|
              attribute_serializer.call(item)
            end
            hash['RequestItems'][table_name] = sub_hash
          end
          hash
        end

        def to_dynamodb_json
          as_dynamodb_json.to_json
        end
      end
    end
  end
end

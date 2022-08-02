# frozen_string_literal: true

module Unity
  module DynamoDB
    module Shapes
      class TransactGetItemsShape
        API_TARGET = 'DynamoDB_20120810.TransactGetItems'

        def initialize(attributes)
          @transact_items = attributes[:transact_items]
          @return_consumed_capacity = attributes[:return_consumed_capacity]
        end

        def as_dynamodb_json
          attribute_serializer = Unity::DynamoDB::AttributeSerializer.new

          hash = Unity::DynamoDB::HashNonNull.new
          hash['ReturnConsumedCapacity'] = @return_consumed_capacity
          hash['TransactItems'] = @transact_items.collect do |item|
            key, value = item.to_a.first

            case key
            when :get
              sub_hash = Unity::DynamoDB::HashNonNull.new
              sub_hash['TableName'] = value[:table_name]
              sub_hash['ExpressionAttributeNames'] = value[:expression_attribute_names]
              sub_hash['ProjectionExpression'] = value[:projection_expression]
              sub_hash['Key'] = attribute_serializer.call(value[:key])
              { 'Get' => sub_hash }
            else
              raise "unknown TransactItem type: #{key}"
            end
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

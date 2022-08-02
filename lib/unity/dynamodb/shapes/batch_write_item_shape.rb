# frozen_string_literal: true

module Unity
  module DynamoDB
    module Shapes
      class BatchWriteItemShape
        API_TARGET = 'DynamoDB_20120810.BatchWriteItem'

        def initialize(attributes)
          @request_items = attributes[:request_items]
          @return_consumed_capacity = attributes[:return_consumed_capacity]
          @return_item_collection_metrics = attributes[:return_item_collection_metrics]
        end

        def as_dynamodb_json
          attribute_serializer = Unity::DynamoDB::AttributeSerializer.new

          hash = Unity::DynamoDB::HashNonNull.new
          hash['ReturnConsumedCapacity'] = @return_consumed_capacity
          hash['ReturnItemCollectionMetrics'] = @return_item_collection_metrics
          hash['RequestItems'] = {}
          @request_items.each do |table_name, items|
            hash['RequestItems'][table_name] = items.map do |item|
              request_type, value = item.to_a.first

              case request_type
              when :delete_request
                { 'DeleteRequest' => { 'Key' => attribute_serializer.call(value[:key]) } }
              when :put_request
                { 'PutRequest' => { 'Item' => attribute_serializer.call(value[:item]) } }
              end
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

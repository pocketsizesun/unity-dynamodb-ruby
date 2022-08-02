# frozen_string_literal: true

module Unity
  module DynamoDB
    module Outputs
      class BatchWriteItemOutput
        attr_reader :unprocessed_items, :consumed_capacity, :item_collection_metrics

        def self.from_dynamodb_json(data)
          attribute_deserializer = Unity::DynamoDB::AttributeDeserializer.new

          new(
            item_collection_metrics: \
              data['ItemCollectionMetrics']&.each_with_object({}) do |(table_name, items), hash|
                hash[table_name] = items.map do |item|
                  {
                    item_collection_key: attribute_deserializer.call(item['ItemCollectionKey']),
                    size_estimate_range_gb: item['SizeEstimateRangeGB']
                  }
                end
              end,
            unprocessed_items: data['UnprocessedItems'].each_with_object({}) do |(table_name, items), hash|
              hash[table_name] = items.collect do |item|
                key, value = item.to_a.first
                case key
                when 'DeleteRequest'
                  {
                    delete_request: {
                      key: attribute_deserializer.call(value)
                    }
                  }
                when 'PutRequest'
                  {
                    put_request: {
                      item: attribute_deserializer.call(value)
                    }
                  }
                end
              end
            end,
            consumed_capacity: data['ConsumedCapacity']
          )
        end

        def initialize(attributes)
          @item_collection_metrics = attributes[:item_collection_metrics]
          @unprocessed_items = attributes[:unprocessed_items]
          @consumed_capacity = attributes[:consumed_capacity]
        end
      end
    end
  end
end

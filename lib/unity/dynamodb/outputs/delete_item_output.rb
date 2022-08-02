# frozen_string_literal: true

module Unity
  module DynamoDB
    module Outputs
      class DeleteItemOutput
        attr_reader :attributes, :consumed_capacity, :item_collection_metrics

        def self.from_dynamodb_json(data)
          attribute_deserializer = Unity::DynamoDB::AttributeDeserializer.new

          new(
            attributes: attribute_deserializer.call(data['Attributes']),
            item_collection_metrics: \
              data['ItemCollectionMetrics']&.each_with_object({}) do |(table_name, items), hash|
                hash[table_name] = items.map do |item|
                  {
                    item_collection_key: attribute_deserializer.call(item['ItemCollectionKey']),
                    size_estimate_range_gb: item['SizeEstimateRangeGB']
                  }
                end
              end,
            consumed_capacity: data['ConsumedCapacity']
          )
        end

        def initialize(attributes)
          @attributes = attributes[:attributes]
          @item_collection_metrics = attributes[:item_collection_metrics]
          @consumed_capacity = attributes[:consumed_capacity]
        end
      end
    end
  end
end

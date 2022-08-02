# frozen_string_literal: true

module Unity
  module DynamoDB
    module Outputs
      class GetItemOutput
        attr_reader :item, :consumed_capacity

        def self.from_dynamodb_json(data)
          attribute_deserializer = Unity::DynamoDB::AttributeDeserializer.new
          new(
            item: \
              unless data['Item'].nil?
                attribute_deserializer.call(data['Item'])
              end,
            consumed_capacity: data['ConsumedCapacity']
          )
        end

        def initialize(attributes)
          @item = attributes[:item]
          @consumed_capacity = attributes[:consumed_capacity]
        end
      end
    end
  end
end

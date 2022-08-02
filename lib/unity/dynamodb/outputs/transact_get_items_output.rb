# frozen_string_literal: true

module Unity
  module DynamoDB
    module Outputs
      class TransactGetItemsOutput
        attr_reader :responses, :consumed_capacity

        def self.from_dynamodb_json(data)
          attribute_deserializer = Unity::DynamoDB::AttributeDeserializer.new

          new(
            responses: data['Responses'].map do |item|
              attribute_deserializer.call(item['Item'])
            end,
            consumed_capacity: data['ConsumedCapacity']
          )
        end

        def initialize(attributes)
          @responses = attributes[:responses]
          @consumed_capacity = attributes[:consumed_capacity]
        end
      end
    end
  end
end

# frozen_string_literal: true

module Unity
  module DynamoDB
    module Outputs
      class QueryOutput
        attr_reader :count, :items, :scanned_count, :consumed_capacity, :last_evaluated_key

        def self.from_dynamodb_json(data)
          attribute_deserializer = Unity::DynamoDB::AttributeDeserializer.new
          new(
            count: data['Count'],
            items: data['Items'].collect do |item|
              attribute_deserializer.call(item)
            end,
            scanned_count: data['ScannedCount'],
            consumed_capacity: data['ConsumedCapacity'],
            last_evaluated_key: \
              unless data['LastEvaluatedKey'].nil?
                attribute_deserializer.call(data['LastEvaluatedKey'])
              end
          )
        end

        def initialize(attributes)
          @count = attributes[:count]
          @items = attributes[:items]
          @scanned_count = attributes[:scanned_count]
          @consumed_capacity = attributes[:consumed_capacity]
          @last_evaluated_key = attributes[:last_evaluated_key]
        end
      end
    end
  end
end

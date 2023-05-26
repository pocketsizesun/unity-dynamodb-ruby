# frozen_string_literal: true

module Unity
  module DynamoDB
    module Outputs
      class ExecuteStatementOutput
        attr_reader :items, :consumed_capacity, :last_evaluated_key, :next_token

        def self.from_dynamodb_json(data)
          attribute_deserializer = Unity::DynamoDB::AttributeDeserializer.new
          new(
            items: data['Items']&.collect do |item|
              attribute_deserializer.call(item)
            end,
            consumed_capacity: data['ConsumedCapacity'],
            next_token: data['NextToken'],
            last_evaluated_key: data['LastEvaluatedKey']
          )
        end

        def initialize(attributes)
          @items = attributes[:items]
          @next_token = attributes[:next_token]
          @consumed_capacity = attributes[:consumed_capacity]
          @last_evaluated_key = attributes[:last_evaluated_key]
        end
      end
    end
  end
end

# frozen_string_literal: true

module Unity
  module DynamoDB
    module Outputs
      class BatchGetItemOutput
        attr_reader :unprocessed_keys, :responses, :consumed_capacity

        def self.from_dynamodb_json(data)
          attribute_deserializer = Unity::DynamoDB::AttributeDeserializer.new

          new(
            responses: data['Responses'].each_with_object({}) do |(table_name, items), hash|
              hash[table_name] = items.map do |item|
                attribute_deserializer.call(item)
              end
            end,
            unprocessed_keys: data['UnprocessedKeys'].each_with_object({}) do |(table_name, params), hash|
              hash[table_name] = {
                consistent_read: params['ConsistentRead'],
                expression_attribute_names: params['ExpressionAttributeNames'],
                keys: params['Keys'].map do |item|
                  attribute_deserializer.call(item)
                end,
                projection_expression: params['ProjectionExpression']
              }
              hash[table_name].compact!
            end,
            consumed_capacity: data['ConsumedCapacity']
          )
        end

        def initialize(attributes)
          @responses = attributes[:responses]
          @unprocessed_keys = attributes[:unprocessed_keys]
          @consumed_capacity = attributes[:consumed_capacity]
        end
      end
    end
  end
end

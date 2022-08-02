# frozen_string_literal: true

module Unity
  module DynamoDB
    module Shapes
      class TransactWriteItemsShape
        API_TARGET = 'DynamoDB_20120810.TransactWriteItems'

        def initialize(attributes)
          @transact_items = attributes[:transact_items]
          @client_request_token = attributes[:client_request_token]
          @return_consumed_capacity = attributes[:return_consumed_capacity]
          @return_item_collection_metrics = attributes[:return_item_collection_metrics]
        end

        def as_dynamodb_json
          attribute_serializer = Unity::DynamoDB::AttributeSerializer.new

          hash = Unity::DynamoDB::HashNonNull.new
          hash['ClientRequestToken'] = @client_request_token
          hash['ReturnConsumedCapacity'] = @return_consumed_capacity
          hash['ReturnItemCollectionMetrics'] = @return_item_collection_metrics
          hash['TransactItems'] = @transact_items.collect do |item|
            operation_type, parameters = item.to_a.first
            sub_hash = Unity::DynamoDB::HashNonNull.new

            case operation_type
            when :condition_check
              sub_hash['ConditionExpression'] = parameters.fetch(:condition_expression)
              sub_hash['ExpressionAttributeNames'] = parameters[:expression_attribute_names]
              sub_hash['ExpressionAttributeValues'] = \
                unless parameters[:expression_attribute_values].nil?
                  attribute_serializer.call(parameters[:expression_attribute_values])
                end
              sub_hash['Key'] = attribute_serializer.call(parameters.fetch(:key))
              sub_hash['ReturnValuesOnConditionCheckFailure'] = parameters[:return_values_on_condition_check_failure]
              sub_hash['TableName'] = parameters.fetch(:table_name)

              { 'ConditionCheck' => sub_hash }
            when :delete
              sub_hash['ConditionExpression'] = parameters[:condition_expression]
              sub_hash['ExpressionAttributeNames'] = parameters[:expression_attribute_names]
              sub_hash['ExpressionAttributeValues'] = \
                unless parameters[:expression_attribute_values].nil?
                  attribute_serializer.call(parameters[:expression_attribute_values])
                end
              sub_hash['Key'] = attribute_serializer.call(parameters.fetch(:key))
              sub_hash['ReturnValuesOnConditionCheckFailure'] = parameters[:return_values_on_condition_check_failure]
              sub_hash['TableName'] = parameters.fetch(:table_name)

              { 'Delete' => sub_hash }
            when :put
              sub_hash['ConditionExpression'] = parameters[:condition_expression]
              sub_hash['ExpressionAttributeNames'] = parameters[:expression_attribute_names]
              sub_hash['ExpressionAttributeValues'] = \
                unless parameters[:expression_attribute_values].nil?
                  attribute_serializer.call(parameters[:expression_attribute_values])
                end
              sub_hash['Item'] = attribute_serializer.call(parameters.fetch(:item))
              sub_hash['ReturnValuesOnConditionCheckFailure'] = parameters[:return_values_on_condition_check_failure]
              sub_hash['TableName'] = parameters[:table_name]

              { 'Put' => sub_hash }
            when :update
              sub_hash['ConditionExpression'] = parameters[:condition_expression]
              sub_hash['ExpressionAttributeNames'] = parameters[:expression_attribute_names]
              sub_hash['ExpressionAttributeValues'] = \
                unless parameters[:expression_attribute_values].nil?
                  attribute_serializer.call(parameters[:expression_attribute_values])
                end
              sub_hash['Key'] = attribute_serializer.call(parameters.fetch(:key))
              sub_hash['ReturnValuesOnConditionCheckFailure'] = parameters[:return_values_on_condition_check_failure]
              sub_hash['TableName'] = parameters.fetch(:table_name)
              sub_hash['UpdateExpression'] = parameters.fetch(:update_expression)

              { 'Update' => sub_hash }
            else
              raise "transact write items unknown operation type: #{operation_type}"
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

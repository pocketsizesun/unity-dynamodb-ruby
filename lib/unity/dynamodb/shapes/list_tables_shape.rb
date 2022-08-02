# frozen_string_literal: true

module Unity
  module DynamoDB
    module Shapes
      class ListTablesShape
        API_TARGET = 'DynamoDB_20120810.ListTables'

        def initialize(attributes)
          @exclusive_start_table_name = attributes[:exclusive_start_table_name]
          @limit = attributes[:limit]
        end

        def as_dynamodb_json
          hash = Unity::DynamoDB::HashNonNull.new
          hash['ExclusiveStartTableName'] = @exclusive_start_table_name
          hash['Limit'] = @limit
          hash
        end

        def to_dynamodb_json
          as_dynamodb_json.to_json
        end
      end
    end
  end
end

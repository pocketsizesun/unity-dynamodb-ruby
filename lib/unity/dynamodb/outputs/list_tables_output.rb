# frozen_string_literal: true

module Unity
  module DynamoDB
    module Outputs
      class ListTablesOutput
        attr_reader :last_evaluated_table_name, :table_names

        def self.from_dynamodb_json(data)
          new(
            last_evaluated_table_name: data['LastEvaluatedTableName'],
            table_names: data['TableNames']
          )
        end

        def initialize(attributes)
          @last_evaluated_table_name = attributes[:last_evaluated_table_name]
          @table_names = attributes[:table_names]
        end
      end
    end
  end
end

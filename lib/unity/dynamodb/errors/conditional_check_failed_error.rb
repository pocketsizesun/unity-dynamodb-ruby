# frozen_string_literal: true

module Unity
  module DynamoDB
    module Errors
      class ConditionalCheckFailedError < Unity::DynamoDB::Error
        def initialize(message)
          super("conditional check failed: #{message}")
        end
      end
    end
  end
end

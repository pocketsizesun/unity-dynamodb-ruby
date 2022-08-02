# frozen_string_literal: true

module Unity
  module DynamoDB
    module Errors
      class ValidationError < Unity::DynamoDB::Error
        def initialize(message)
          super("validation error: #{message}")
        end
      end
    end
  end
end

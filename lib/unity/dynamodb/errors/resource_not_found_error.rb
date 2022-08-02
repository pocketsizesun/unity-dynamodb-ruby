# frozen_string_literal: true

module Unity
  module DynamoDB
    module Errors
      class ResourceNotFoundError < Unity::DynamoDB::Error
        def initialize(message)
          super("resource not found: #{message}")
        end
      end
    end
  end
end

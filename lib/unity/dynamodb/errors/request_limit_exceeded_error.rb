# frozen_string_literal: true

module Unity
  module DynamoDB
    module Errors
      class RequestLimitExceededError < Unity::DynamoDB::Error
        def initialize(message)
          super("request limit exceeded: #{message}")
        end
      end
    end
  end
end

# frozen_string_literal: true

module Unity
  module DynamoDB
    module Errors
      class ProvisionedThroughputExceededError < Unity::DynamoDB::Error
        def initialize(message)
          super("provisioned throughput exceeded: #{message}")
        end
      end
    end
  end
end

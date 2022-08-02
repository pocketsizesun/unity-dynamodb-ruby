# frozen_string_literal: true

module Unity
  module DynamoDB
    module Errors
      class ProvisionedThroughputExceededError < Unity::DynamoDB::Error
      end
    end
  end
end

# frozen_string_literal: true

module Unity
  module DynamoDB
    module Errors
      class ProvisionedThroughputExceededException < Unity::DynamoDB::RetryableError
      end
    end
  end
end

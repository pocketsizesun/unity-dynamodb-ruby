# frozen_string_literal: true

module Unity
  module DynamoDB
    module Errors
      class InternalServerError < Unity::DynamoDB::RetryableError
      end
    end
  end
end

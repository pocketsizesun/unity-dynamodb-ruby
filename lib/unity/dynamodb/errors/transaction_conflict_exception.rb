# frozen_string_literal: true

module Unity
  module DynamoDB
    module Errors
      class TransactionConflictException < Unity::DynamoDB::Error
      end
    end
  end
end

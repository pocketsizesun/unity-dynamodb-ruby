# frozen_string_literal: true

module Unity
  module DynamoDB
    module Errors
      class TransactionCanceledError < Unity::DynamoDB::Error
        def initialize(message)
          super("transaction canceled: #{message}")
        end
      end
    end
  end
end

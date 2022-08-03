# frozen_string_literal: true

module Unity
  module DynamoDB
    module Errors
      class TransactionCanceledError < Unity::DynamoDB::Error
        attr_reader :reasons

        def initialize(message, reasons)
          super(message)
          @reasons = reasons
        end
      end
    end
  end
end

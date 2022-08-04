# frozen_string_literal: true

module Unity
  module DynamoDB
    module Errors
      class TransactionCanceledException < Unity::DynamoDB::Error
        attr_reader :reasons

        def initialize(message, reasons)
          super(message)
          @reasons = reasons
        end

        def any_transaction_conflict?
          @reasons.any? do |reason|
            reason['Code'] == 'TransactionConflict'
          end
        end
      end
    end
  end
end

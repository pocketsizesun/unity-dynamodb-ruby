# frozen_string_literal: true

module Unity
  module DynamoDB
    module Errors
      class UnknownError < Unity::DynamoDB::Error
        attr_reader :type

        def initialize(type, message)
          @type = type
          super(message)
        end
      end
    end
  end
end

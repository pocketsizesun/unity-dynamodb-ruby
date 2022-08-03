# frozen_string_literal: true

module Unity
  module DynamoDB
    class StringSet < ::Set
      def initialize(arr = [])
        super(arr.map(&:to_s))
      end

      def add(value)
        super(value.to_s)
      end
    end
  end
end

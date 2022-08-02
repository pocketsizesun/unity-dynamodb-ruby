# frozen_string_literal: true

module Unity
  module DynamoDB
    class HashNonNull < Hash
      def []=(key, value)
        return if value.nil?

        super
      end
    end
  end
end

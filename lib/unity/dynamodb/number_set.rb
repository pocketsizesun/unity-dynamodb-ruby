# frozen_string_literal: true

module Unity
  module DynamoDB
    class NumberSet < ::Set
      def initialize(arr = [])
        super(
          arr.map do |item|
            BigDecimal(item.to_s)
          end
        )
      end

      def add(value)
        super(BigDecimal(value.to_s))
      end
    end
  end
end

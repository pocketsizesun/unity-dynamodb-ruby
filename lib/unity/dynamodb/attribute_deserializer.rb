# frozen_string_literal: true

module Unity
  module DynamoDB
    class AttributeDeserializer
      def self.call(hash)
        return unless hash.is_a?(Hash)

        hash.transform_values { |v| translate(v) }
      end

      def self.translate(arg)
        type = arg.keys[0]
        value = arg[type]
        case type
        when 'N' then BigDecimal(value)
        when 'L'
          value.map { |item| translate(item) }
        when 'SS'
          Set.new(value)
        when 'NS'
          Set.new(value.map(&:to_s))
        when 'M'
          value.transform_values { |item| translate(item) }
        when 'S' then value.to_s
        when 'B' then StringIO.new(Base64.decode64(value))
        when 'BS'
          Set.new(value.map { |item| StringIO.new(Base64.decode64(item)) })
        when 'NULL' then nil
        when 'BOOL' then value
        else value
        end
      end
    end
  end
end

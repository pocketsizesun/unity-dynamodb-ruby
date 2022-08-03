# frozen_string_literal: true

module Unity
  module DynamoDB
    class AttributeSerializer
      def self.call(hash)
        new.call(hash)
      end

      def call(hash)
        return unless hash.is_a?(Hash)

        hash.transform_values { |v| translate(v) }
      end

      def translate(arg)
        case arg
        when Numeric then { 'N' => arg.to_s }
        when String then { 'S' => arg }
        when Array
          arg.map { |item| translate(item) }
        when Unity::DynamoDB::StringSet
          { 'SS' => arg.to_a }
        when Unity::DynamoDB::NumberSet
          { 'NS' => arg.to_a }
        when Set
          case arg.first
          when String
            { 'SS' => arg.map { |item| translate(item.to_s) } }
          when StringIO
            { 'BS' => arg.map { |item| Base64.encode64(item.read) } }
          when Numeric
            { 'NS' => arg.map { |item| translate(item.to_i) } }
          else
            raise "unknown set type: #{arg.first.class}"
          end
        when Hash
          { 'M' => arg.transform_values { |item| translate(item) } }
        when StringIO
          { 'B' => Base64.encode64(item.read) }
        when NilClass
          { 'NULL' => true }
        when TrueClass, FalseClass
          { 'BOOL' => arg }
        else
          raise "unknown type: #{arg.class}"
        end
      end
    end
  end
end

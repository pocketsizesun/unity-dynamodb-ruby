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
          value.map { |item| translate(item) }
        when Set
          case value.first
          when String
            { 'SS' => value.map { |item| translate(item.to_s) } }
          when StringIO
            { 'BS' => value.map { |item| Base64.encode64(item.read) } }
          when Numeric
            { 'NS' => value.map { |item| translate(item.to_i) } }
          else
            raise "unknown set type: #{value.first.class}"
          end
        when Hash
          value.transform_values { |item| translate(item) }
        when StringIO
          { 'B' => Base64.encode64(item.read) }
        when NilClass
          { 'NULL' => true }
        when TrueClass, FalseClass
          { 'BOOL' => value }
        else
          raise "unknown type: #{arg.class}"
        end
      end
    end
  end
end

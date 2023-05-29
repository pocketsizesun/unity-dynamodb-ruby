# frozen_string_literal: true

require_relative "attribute_deserializer"

module Unity
  module DynamoDB
    class StreamEventParser
      def initialize
        @deserializer = Unity::DynamoDB::AttributeDeserializer.new
      end

      def call(hash)
        stream_event = Unity::DynamoDB::StreamEvent.from_json(hash)
      end
    end
  end
end

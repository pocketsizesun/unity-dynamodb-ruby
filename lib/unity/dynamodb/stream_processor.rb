# frozen_string_literal: true

module Unity
  module DynamoDB
    class StreamProcessor
      class Table
        def initialize(name)
          @name = name
          @handlers = {
            'INSERT' => [],
            'MODIFY' => [],
            'REMOVE' => []
          }.freeze
        end

        # @param stream_event [Unity::DynamoDB::StreamEvent]
        # @return [void]
        def call(stream_event)
          @handlers[stream_event.event_name].each do |handler|
            handler.call(stream_event)
          end
        end

        def on(type, klass = nil, &block)
          @handlers[type] << klass || block
        end

        def on_insert(klass = nil, &block)
          on('INSERT', klass, &block)
        end

        def on_modify(klass = nil, &block)
          on('MODIFY', klass, &block)
        end

        def on_remove(klass = nil, &block)
          on('REMOVE', klass, &block)
        end
      end

      def initialize(&block)
        @tables = {}
        instance_exec(&block) unless block.nil?
      end

      def table(name, &block)
        @tables[name] ||= Table.new(name)
        @tables[name].instance_exec(&block)
      end

      # @param stream_event [Unity::DynamoDB::StreamEvent]
      # @return [void]
      def call(stream_event)
        return if @tables[stream_event.table_name].nil?

        @tables[stream_event.table_name].call(stream_event)
      end
    end
  end
end

# frozen_string_literal: true

require_relative "attribute_deserializer"

module Unity
  module DynamoDB
    class StreamEventParser
      EventStruct = Struct.new(
        :event_id, :event_name, :event_version, :event_source, :event_source_arn,
        :aws_region, :dynamodb, :user_identity, :table_name
      )

      StreamRecordStruct = Struct.new(
        :approximate_creation_date_time,
        :keys,
        :new_image,
        :old_image,
        :sequence_number,
        :size_bytes,
        :stream_view_type
      )

      def initialize
        @deserializer = Unity::DynamoDB::AttributeDeserializer.new
      end

      def call(hash)
        EventStruct.new(
          hash['eventID'], # event_id
          hash['eventName'], # event_name
          hash['eventVersion'], # event_version
          hash['eventSource'], # event_source
          hash['eventSourceARN'], # event_source_arn
          hash['awsRegion'], # aws_region
          StreamRecordStruct.new( # dynamodb
            hash['dynamodb']['ApproximateCreationDateTime'],
            @deserializer.call(hash['dynamodb']['Keys']),
            @deserializer.call(hash['dynamodb']['NewImage']),
            @deserializer.call(hash['dynamodb']['OldImage']),
            hash['dynamodb']['SequenceNumber'],
            hash['dynamodb']['SizeBytes'],
            hash['dynamodb']['StreamViewType']
          ),
          hash['userIdentity'], # user_identity
          hash['eventSourceARN']&.split('/', 3)&.at(1) # table_name
        )
      end
    end
  end
end

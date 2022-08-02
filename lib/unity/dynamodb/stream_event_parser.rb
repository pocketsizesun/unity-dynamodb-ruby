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
          hash['eventID'],
          hash['eventName'],
          hash['eventVersion'],
          hash['eventSource'],
          hash['eventSourceARN'],
          hash['awsRegion'],
          StreamRecordStruct.new(
            hash['dynamodb']['ApproximateCreationDateTime'],
            @deserializer.call(hash['dynamodb']['Keys']),
            @deserializer.call(hash['dynamodb']['NewImage']),
            @deserializer.call(hash['dynamodb']['OldImage']),
            hash['dynamodb']['SequenceNumber'],
            hash['dynamodb']['SizeBytes'],
            hash['dynamodb']['StreamViewType']
          ),
          hash['userIdentity'],
          hash['eventSourceARN']&.split('/', 3)&.at(1)
        )
      end
    end
  end
end

# frozen_string_literal: true

module Unity
  module DynamoDB
    class StreamEvent
      attr_accessor :event_id
      attr_accessor :event_name
      attr_accessor :event_version
      attr_accessor :event_source
      attr_accessor :event_source_arn
      attr_accessor :aws_region
      attr_accessor :dynamodb
      attr_accessor :user_identity
      attr_accessor :table_name

      def self.from_json(json)
        obj = new
        obj.event_id = hash['eventID'] # event_id
        obj.event_name = hash['eventName'] # event_name
        obj.event_version = hash['eventVersion'] # event_version
        obj.event_source = hash['eventSource'] # event_source
        obj.event_source_arn = hash['eventSourceARN'] # event_source_arn
        obj.aws_region = hash['awsRegion'] # aws_region
        obj.dynamodb = Record.from_json(hash['dynamodb'])
        obj.user_identity = hash['userIdentity'] # user_identity
        obj.table_name = hash['eventSourceARN']&.split('/', 3)&.at(1) # table_name
        obj
      end

      class Record
        attr_accessor :approximate_creation_date_time
        attr_accessor :keys
        attr_accessor :new_image
        attr_accessor :old_image
        attr_accessor :sequence_number
        attr_accessor :size_bytes
        attr_accessor :stream_view_type

        def self.from_json(json)
          obj = new
          obj.approximate_creation_date_time = hash['dynamodb']['ApproximateCreationDateTime']
          obj.keys = Unity::DynamoDB::AttributeDeserializer.call(
            hash['dynamodb']['Keys']
          )
          obj.new_image = Unity::DynamoDB::AttributeDeserializer.call(
            hash['dynamodb']['NewImage']
          )
          obj.old_image = Unity::DynamoDB::AttributeDeserializer.call(
            hash['dynamodb']['OldImage']
          )
          obj.sequence_number = hash['dynamodb']['SequenceNumber']
          obj.size_bytes = hash['dynamodb']['SizeBytes']
          obj.stream_view_type = hash['dynamodb']['StreamViewType']
          obj
        end
      end
    end
  end
end

require 'bundler/setup'
require "unity/dynamodb/stream_event_parser"

RSpec.describe Unity::DynamoDB::StreamEventParser do
  it "should decode a DynamoDB Streams INSERT event" do
    event = {
      'eventID' => '1',
      'eventName' => 'INSERT',
      'eventVersion' => '1.0',
      'eventSource' => 'aws:dynamodb',
      'awsRegion' => 'us-east-1',
      'dynamodb' => {
        'Keys' => { 'id' => { 'N' => '101' } },
        'NewImage' => {
          'id' => { 'N' => '101' },
          'message' => { 'S' => 'Hello world!' }
        },
        'SequenceNumber' => '111',
        'SizeBytes' => 26,
        'StreamViewType' => 'NEW_AND_OLD_IMAGES',
        'ApproximateCreationDateTime' => 1633768788
      },
      'eventSourceARN' => 'arn:aws:dynamodb:us-east-1:111122223333:table/TestTable/stream/2015-05-11T21:21:33.291'
    }

    event_parser = Unity::DynamoDB::StreamEventParser.new
    parsed_event = event_parser.call(event)
    pp parsed_event
    expect(parsed_event.event_id).to(eql('1'))
    expect(parsed_event.event_name).to(eql('INSERT'))
    expect(parsed_event.event_version).to(eql('1.0'))
    expect(parsed_event.event_source).to(eql('aws:dynamodb'))
    expect(parsed_event.event_source_arn).to(eql('arn:aws:dynamodb:us-east-1:111122223333:table/TestTable/stream/2015-05-11T21:21:33.291'))
    expect(parsed_event.aws_region).to(eql('us-east-1'))
    expect(parsed_event.event_source).to(eql('aws:dynamodb'))
    expect(parsed_event.user_identity).to(eql(nil))
    expect(parsed_event.dynamodb.approximate_creation_date_time).to(eql(1633768788))
    expect(parsed_event.dynamodb.keys).to(eql({ 'id' => BigDecimal(101) }))
    expect(parsed_event.dynamodb.new_image).to(eql({ 'id' => BigDecimal(101), 'message' => 'Hello world!' }))
    expect(parsed_event.dynamodb.old_image).to(eql(nil))
    expect(parsed_event.dynamodb.sequence_number).to(eql('111'))
    expect(parsed_event.dynamodb.size_bytes).to(eql(26))
    expect(parsed_event.dynamodb.stream_view_type).to(eql('NEW_AND_OLD_IMAGES'))
  end
end

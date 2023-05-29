# frozen_string_literal: true

require 'http'
require 'uri'
require 'json'
require 'bigdecimal'
require 'base64'
require 'aws-sdk-core'
require 'aws-sigv4'
require_relative "dynamodb/version"
require_relative "dynamodb/error"
require_relative "dynamodb/attribute_serializer"
require_relative "dynamodb/attribute_deserializer"

# DynamoDB Streams Utilities
require_relative "dynamodb/stream_event"
require_relative "dynamodb/stream_processor"

# DynamoDB Class Types
require_relative "dynamodb/number_set"
require_relative "dynamodb/string_set"

module Unity
  module DynamoDB
  end
end

# frozen_string_literal: true

require 'http'
require 'uri'
require 'json'
require 'bigdecimal'
require 'base64'
require 'aws-sdk-core'
require 'aws-sigv4'
require_relative "dynamodb/version"
require_relative "dynamodb/client"
require_relative "dynamodb/hash_non_null"
require_relative "dynamodb/attribute_serializer"
require_relative "dynamodb/attribute_deserializer"

# errors
require_relative "dynamodb/error"
require_relative "dynamodb/errors/conditional_check_failed_error"
require_relative "dynamodb/errors/provisioned_throughput_exceeded_error"
require_relative "dynamodb/errors/request_limit_exceeded_error"
require_relative "dynamodb/errors/resource_not_found_error"
require_relative "dynamodb/errors/transaction_canceled_error"
require_relative "dynamodb/errors/unknown_error"
require_relative "dynamodb/errors/validation_error"

# shapes
require_relative "dynamodb/shapes/batch_get_item_shape"
require_relative "dynamodb/shapes/batch_write_item_shape"
require_relative "dynamodb/shapes/delete_item_shape"
require_relative "dynamodb/shapes/get_item_shape"
require_relative "dynamodb/shapes/list_tables_shape"
require_relative "dynamodb/shapes/put_item_shape"
require_relative "dynamodb/shapes/query_shape"
require_relative "dynamodb/shapes/scan_shape"
require_relative "dynamodb/shapes/transact_get_items_shape"
require_relative "dynamodb/shapes/transact_write_items_shape"
require_relative "dynamodb/shapes/update_item_shape"

# outputs
require_relative "dynamodb/outputs/batch_get_item_output"
require_relative "dynamodb/outputs/batch_write_item_output"
require_relative "dynamodb/outputs/delete_item_output"
require_relative "dynamodb/outputs/get_item_output"
require_relative "dynamodb/outputs/list_tables_output"
require_relative "dynamodb/outputs/put_item_output"
require_relative "dynamodb/outputs/query_output"
require_relative "dynamodb/outputs/scan_output"
require_relative "dynamodb/outputs/transact_get_items_output"
require_relative "dynamodb/outputs/transact_write_items_output"
require_relative "dynamodb/outputs/update_item_output"

module Unity
  module DynamoDB
  end
end

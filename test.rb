require 'bundler/setup'
require 'unity-dynamodb'
require 'benchmark'

client = Unity::DynamoDB::Client.new
puts '----------- EXECUTE STATEMENT'
dates = (Date.parse('2022-06-01')..Date.parse('2022-06-30')).map(&:to_s)
placeholders = dates.map { '?' }

execute_statement_params = {
  statement: "SELECT * FROM \"test\" WHERE \"date\" IN(#{placeholders.join(', ')}) AND \"id\" >= ?",
  limit: 1,
  parameters: dates + [1654063200]
}
pp execute_statement_params
loop do
  result = client.execute_statement(execute_statement_params)
  pp result.items
  pp result.next_token
  break if result.next_token.nil?

  execute_statement_params[:next_token] = result.next_token
end

exit

puts '----------- QUERY'
pp client.query(
  table_name: 'test',
  limit: 1,
  key_condition_expression: '#date = :date',
  expression_attribute_names: {
    '#date' => 'date'
  },
  expression_attribute_values: {
    ':date' => '2022-06-02'
  }
)
pp client.query(
  table_name: 'test',
  key_condition_expression: '#date = :date',
  expression_attribute_names: {
    '#date' => 'date'
  },
  expression_attribute_values: {
    ':date' => '2022-06-02'
  },
  exclusive_start_key: { "id" => 0.16541496e10, "date" => "2022-06-02" }
)
pp client.query(
  table_name: 'test',
  key_condition_expression: '#date = :date',
  expression_attribute_names: {
    '#date' => 'date'
  },
  expression_attribute_values: {
    ':date' => '2022-06-02'
  }
)

puts '----------- SCAN'
result = client.scan(
  table_name: 'test',
  limit: 1
)
pp result
pp client.scan(
  table_name: 'test',
  limit: 1,
  exclusive_start_key: result.last_evaluated_key
)
pp client.scan(
  table_name: 'test'
)

puts '----------- BATCH_GET_ITEM'
pp client.batch_get_item(
  request_items: {
    'test' => {
      keys: [
        { 'date' => '2021-01-01', 'id' => 0.1654156401e10 }
      ]
    }
  }
)

puts '----------- GET ITEM'
pp client.get_item(
  table_name: 'test',
  key: { 'date' => '2021-01-01', 'id' => 0.1654156401e10 }
)

puts '----------- PUT ITEM'
pp client.put_item(
  table_name: 'test',
  item: { 'date' => 'test', 'id' => 1000 },
  return_values: 'ALL_OLD'
)

pp client.put_item(
  table_name: 'test',
  item: { 'date' => 'test', 'id' => 2000 },
  return_values: 'ALL_OLD'
)

pp client.put_item(
  table_name: 'test',
  item: { 'date' => 'test', 'id' => 3000 },
  return_values: 'ALL_OLD'
)

puts '----------- BATCH WRITE ITEM'
pp client.batch_write_item(
  return_consumed_capacity: 'TOTAL',
  return_item_collection_metrics: 'SIZE',
  request_items: {
    'test' => [
      {
        put_request: {
          item: {
            'date' => 'test',
            'id' => 1
          }
        }
      },
      {
        put_request: {
          item: {
            'date' => 'test',
            'id' => 5000
          }
        }
      },
      {
        delete_request: {
          key: {
            'date' => 'test',
            'id' => 1000
          }
        }
      }
    ]
  }
)

puts '----------- DELETE ITEM'
pp client.delete_item(
  table_name: 'test',
  return_values: 'ALL_OLD',
  key: { 'date' => 'test', 'id' => 2000 }
)

pp client.delete_item(
  table_name: 'test',
  return_values: 'ALL_OLD',
  key: { 'date' => 'test', 'id' => 4000 }
)

puts '----------- UPDATE ITEM'
pp client.update_item(
  table_name: 'test',
  return_values: 'ALL_NEW',
  key: { 'date' => 'test', 'id' => 3000 },
  expression_attribute_names: { '#email' => 'email_address' },
  expression_attribute_values: { ':email' => 'super@juju.fr' },
  update_expression: 'SET #email = :email'
)

puts '----------- TRANSACT GET ITEMS'
pp client.transact_get_items(
  return_consumed_capacity: 'TOTAL',
  transact_items: [
    {
      get: {
        table_name: 'test',
        key: { 'date' => 'test', 'id' => 3000 }
      }
    }
  ]
)

puts '----------- TRANSACT WRITE ITEMS'
pp client.transact_write_items(
  return_consumed_capacity: 'TOTAL',
  transact_items: [
    {
      condition_check: {
        table_name: 'test',
        key: { 'date' => 'test', 'id' => 3000 },
        condition_expression: 'attribute_exists(#date) AND attribute_exists(#id) AND #email = :email',
        expression_attribute_names: {
          '#date' => 'date',
          '#id' => 'id',
          '#email' => 'email_address'
        },
        expression_attribute_values: {
          ':email' => 'super@juju.fr'
        }
      }
    },
    {
      put: {
        table_name: 'test',
        condition_expression: 'attribute_not_exists(#date) AND attribute_not_exists(#id)',
        expression_attribute_names: {
          '#date' => 'date',
          '#id' => 'id'
        },
        item: { 'date' => 'test', 'id' => 4000 }
      }
    },
    {
      delete: {
        table_name: 'test',
        condition_expression: 'attribute_exists(#date) AND attribute_exists(#id)',
        expression_attribute_names: { '#date' => 'date', '#id' => 'id' },
        key: { 'date' => 'test', 'id' => 5000 }
      }
    },
    {
      update: {
        table_name: 'test',
        expression_attribute_names: { '#counter' => 'my_super_counter' },
        expression_attribute_values: { ':value' => 1 },
        key: { 'date' => 'test', 'id' => 6000 },
        update_expression: 'ADD #counter :value'
      }
    }
  ]
)

puts '----------- LIST TABLES'
pp client.list_tables

#### ERRORS
puts '----------- UPDATE ITEM'
pp client.update_item(
  table_name: 'test',
  return_values: 'ALL_NEW',
  condition_expression: 'attribute_not_exists(#date) AND attribute_not_exists(#id)',
  key: { 'date' => 'test', 'id' => 3000 },
  expression_attribute_names: { '#date' => 'date', '#id' => 'id', '#email' => 'email_address' },
  expression_attribute_values: { ':email' => 'super@juju.fr' },
  update_expression: 'SET #email = :email'
)

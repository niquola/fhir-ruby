require 'active_support'
require 'active_support/core_ext'
require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  host: 'localhost',
  port: 5432,
  username: 'postgres',
  password: 'postgres',
  database: 'fhir'
)

ActiveRecord::Schema.define do
  eval File.read('migrations/schema.rb')
end

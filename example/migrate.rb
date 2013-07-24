require 'active_support'
require 'active_support/core_ext'
require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  host: '/home/nicola/pg/',
  port: 5555,
  username: 'nicola',
  database: 'fhir'
)

ActiveRecord::Schema.define do
  eval File.read('migrations/schema.rb')
end

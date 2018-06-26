require 'faraday'
require 'oj'
require 'awesome_print'
require 'json'
require 'dotenv/load'

VALID_TYPES = %w(text number date datetime)
API_KEYS = {
  staging: ENV['STAGING'],
  production: ENV['PRODUCTION']
}
URL_ROOT = 'https://app.close.io/api/v1'
LEAD_FIELDS_URL = 'custom_fields/lead/'

def create_fields(field_name, type)
  payload = {
    name: field_name,
    type: type
  }

  API_KEYS.each do |environment, api_key|
    next if environment == :production && ARGV[3] == 'sandbox'

    response = conn(api_key).post do |req|
      req.url LEAD_FIELDS_URL
      req.body = payload.to_json
    end

    body = Oj.load(response.body)

    if response.success?
      ap "***** FOR #{environment.upcase} *****"
      ap "CUSTOM_FIELD_ID: #{body['id']}"
      ap "CUSTOM_FIELD_NAME: #{body['name']}"
    else
      ap "Something went wrong when creating custom field for #{environment}!"
      ap body
      exit
    end
  end
end

def list_fields
  API_KEYS.each do |environment, api_key|
    response = conn(api_key).get do |req|
      req.url LEAD_FIELDS_URL
    end

    body = Oj.load(response.body)

    if response.success?
      ap "***** FOR #{environment.upcase} *****"
      ap JSON.parse(response.body)
    else
      ap "Something went wrong when listing custom field for #{environment}!"
      ap body
      exit
    end
  end
end

def conn(api_key)
  Faraday.new(url: URL_ROOT).tap do |faraday|
    faraday.basic_auth api_key, ''
    faraday.headers['Content-Type'] = 'application/json'
  end
end

puts 'Do you want to list or create a field? (list, create)'
decision = ARGV[0]

puts 'Got it. Working on that now.'

if decision == 'list'
  list_fields
elsif decision == 'create'
  field = ARGV[1]
  type = ARGV[2]

  if VALID_TYPES.include?(type)
    create_fields(field, type)
  else
    puts 'Type is invalid'
  end
else
  puts 'Cannot understand your argz. Try again.'
end

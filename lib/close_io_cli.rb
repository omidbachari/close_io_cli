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

def create_field(name, type)
  payload = {
    name: name,
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
      ap body
    else
      ap "Something went wrong when listing custom field for #{environment}!"
      ap body
      exit
    end
  end
end

def delete_field(id)
  API_KEYS.each do |environment, api_key|
    next if environment == :production && ARGV[2] == 'sandbox'

    response = conn(api_key).delete do |req|
      req.url(LEAD_FIELDS_URL + id + '/')
    end

    body = Oj.load(response.body)

    ap "***** FOR #{environment.upcase} *****"
    ap body
  end
end

def put_field(id, name, type)
  payload = {
    name: name,
    type: type
  }

  API_KEYS.each do |environment, api_key|
    next if environment == :production && ARGV[4] == 'sandbox'

    response = conn(api_key).put do |req|
      req.url(LEAD_FIELDS_URL + id + '/')
      req.body = payload.to_json
    end

    body = Oj.load(response.body)

    ap "***** FOR #{environment.upcase} *****"
    ap body
  end
end

def conn(api_key)
  Faraday.new(url: URL_ROOT).tap do |faraday|
    faraday.basic_auth api_key, ''
    faraday.headers['Content-Type'] = 'application/json'
  end
end

decision = ARGV[0]
puts 'Got it. Working on that now.'

if decision == 'list'
  list_fields
elsif decision == 'create'
  name = ARGV[1]
  type = ARGV[2]

  if VALID_TYPES.include?(type)
    create_field(name, type)
  else
    puts 'Type is invalid'
  end
elsif decision == 'delete'
  name = ARGV[1]

  delete_field(name)
elsif decision == 'update'
  id = ARGV[1]
  name = ARGV[2]
  type = ARGV[3]

  if VALID_TYPES.include?(type)
    put_field(id, name, type)
  else
    puts 'Type is invalid'
  end
else
  puts 'Cannot understand your argz. Try again.'
end

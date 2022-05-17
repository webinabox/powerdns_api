# frozen_string_literal: true
require 'dry-configurable'
require 'httparty'

require_relative 'powerdns_api/version'

module PowerdnsApi
  autoload :Object, 'powerdns_api/object'
  autoload :Server, 'powerdns_api/server'
  autoload :Zone, 'powerdns_api/zone'
  # autoload :CryptoKey, 'powerdns_api/crypto_key'
  # autoload :Metadata, 'powerdns_api/metadata'
  # autoload :TSIGKey, 'powerdns_api/tsig_key'
  # autoload :AutoPrimary, 'powerdns_api/auto_primary'
  # autoload :Record, 'powerdns_api/record'
  # autoload :RecordSet, 'powerdns_api/record_set'
  # autoload :Search, 'powerdns_api/search'
  # autoload :Cache, 'powerdns_api/cache'

  extend Dry::Configurable
  setting :base_url, default: ENV['POWERDNS_API_URL']
  setting :api_key, default: ENV['POWERDNS_API_KEY']
  setting :server_id, default: 'localhost'
  setting :debug, default: true

  class Base
    include HTTParty
    headers 'Content-Type' => 'application/json'
    format :json

    def self.make_request(path, method, params: {}, body: {})
      options = {}
      options[:query] = params unless params.empty?
      options[:body] = body unless body.empty?

      options[:base_uri] = sprintf '%<base_url>s/servers/%<server_id>s', {
        base_url: PowerdnsApi.config.base_url, server_id: PowerdnsApi.config.server_id
      }
      options[:debug_output] = $stdout if PowerdnsApi.config.debug
      options[:headers] = { 'X-API-KEY' => PowerdnsApi.config.api_key }
      send(method, path, options)
    end
  end

  class Error < StandardError; end

  # Your code goes here...
end

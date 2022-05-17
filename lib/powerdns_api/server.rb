# frozen_string_literal: true

module PowerdnsApi
  # The server endpoint is the ‘basis’ for all other API operations.
  # In the PowerDNS Authoritative Server, the server_id is always localhost.
  # However, the API is written in a way that a proxy could be in
  # front of many servers, each with their own server_id.
  class Server < Object

    def self.all
      Base.make_request('/servers', :get).collect { |server| new(server) }
    end

    def self.find(id)
      new(Base.make_request("/servers/#{id}", :get))
    end

  end
end

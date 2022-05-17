# frozen_string_literal: true

module PowerdnsApi
  # Manipulating zones is the primary use of the API.
  class Zone < Object

    # Returns a list of all zones.
    # @return [Array]
    def self.all
      Base.make_request('/zones',
                        :get).collect { |zone| new(zone) }
    end

    # Find a specific zone, by id
    # @param id [Integer] - The id of the zone to find
    # @return [PowerdnsApi::Zone] - the zone
    def self.find(id)
      new(Base.make_request("/zones/#{id}", :get))
    end

    # Create a new zone
    # @param nameservers [Array] - Name Servers for the zone
    # @param soa_edit [String] - The SOA-EDIT setting for the zone
    # @return [PowerdnsApi::Zone] - the new zone
    def create(nameservers: [], soa_edit: 'EPOCH')
      self.nameservers = nameservers
      self.soa_edit = soa_edit
      self.soa_edit_api = soa_edit

      response = Base.make_request('/zones', :post, body: self.to_h.to_json)

      response.success? ? Zone.find(name) : raise("Failed to create zone: #{response.body}")
    end

    # Add a new record/record set to a zone.
    # @param name [String] - The name of the record
    # @param type [String] - The type of the record
    # @param records [Array] - The records to add
    # @return [PowerdnsApi::Record] - the record
    # Note: will overwrite any existing records with the same name and type
    def create_record(name, type, ttl = 3600, *records)
      update_record(name, type, ttl, records)
    end

    # Update the records/record sets for the zone
    # This can be a single record, or an array of records (RRSet)
    # param name [String] the name of the record (www, or empty for the root)
    # param type [String] the type of record (A/NS/PTR, etc)
    # param records [PowerdnsApi::Record / Array] - the records to update
    # @return [Boolean] - true on success, exception with errors on failure
    def update_record(name, type, ttl = 3600, *records)
      record_set = { name: name, type: type,
                     ttl: ttl, changetype: 'REPLACE',
                     records: [] }

      record_set[:records] = records.map(&:to_hash)

      req = Base.make_request("/zones/#{id}",
                              :patch, body: { rrsets: [record_set] }.to_json)

      req.success?
    end

    # Delete a record from the zone
    # param name [String] the name of the record (www, or empty for the root)
    # param type [String] the type of record (A/NS/PTR, etc)
    # @return [Boolean] - true on success, exception with errors on failure
    def delete_record(name, type)
      record_set = { name: name, type: type,
                     changetype: 'DELETE',
                     records: [] }

      req = Base.make_request("/zones/#{id}",
                              :patch, body: { rrsets: [record_set] }.to_json)

      req.success?
    end

  end
end

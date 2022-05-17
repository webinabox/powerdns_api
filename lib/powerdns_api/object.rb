# frozen_string_literal: true

module PowerdnsApi
  # Base class for PowerDNS objects
  # Inherited by objects returned from the API
  class Object < OpenStruct
    def initialize(attributes)
      super to_ostruct(attributes)
    end

    def to_ostruct(obj)
      case obj
      when Hash
        OpenStruct.new(obj.transform_values { |val| to_ostruct(val) })
      when Array
        obj.map { |o| to_ostruct(o) }
      else
        obj # Assumed to be a primitive value
      end
    end

    def attributes=(attributes)
      attributes.each { |k, v| send("#{k}=", v) }
    end
  end
end

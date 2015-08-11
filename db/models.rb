require "mongoid-cached-json"

class Line
  include Mongoid::Document
  include Mongoid::CachedJson
  field :name, type: String
  field :query, type: String
  field :status, type: String
  field :service_id, type: String

  json_fields \
    name: {},
    status: {}
end

class Service
  include Mongoid::Document
  field :name, type: String
end

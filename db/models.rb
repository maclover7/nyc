class Line
  include Mongoid::Document
  field :name, type: String
  field :query, type: String
  field :status, type: String
  field :service_id, type: String
  belongs_to :service
end

class Service
  include Mongoid::Document
  field :name, type: String
  has_many :lines
end

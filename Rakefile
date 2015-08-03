require "rake/testtask"
require "pry"
require 'mongoid'
require_relative File.join("db/models.rb")

# Import any external rake tasks
Dir.glob('tasks/*.rake').each { |r| import r }

namespace :db do
  desc "Initialize Database"
  task :setup do
    Mongoid.load!("db/mongoid.yml", :development)
    puts "Connected to the database..."
    unless Service.where(name: "nyct").any?
      puts "Creating service records..."
      Service.create(name: "nyct")
      Service.create(name: "lirr")
      Service.create(name: "mnr")
    end

    unless Line.where(name: "ACE", service_id: !0).any?
      # NYCT
      puts "Creating NYCT line records..."
      nyct = Service.find_by(name: "nyct")._id.to_s
      Line.create(name: "ACE", service_id: nyct)
      Line.create(name: "BDFM", service_id: nyct)
      Line.create(name: "G", service_id: nyct)
      Line.create(name: "JZ", service_id: nyct)
      Line.create(name: "L", service_id: nyct)
      Line.create(name: "NQR", service_id: nyct)
      Line.create(name: "S", service_id: nyct)
      Line.create(name: "123", service_id: nyct)
      Line.create(name: "456", service_id: nyct)
      Line.create(name: "7", service_id: nyct)
    end

    unless Line.where(name: "Hudson", service_id: !0).any?
      # MNR
      puts "Creating MNR line records..."
      mnr = Service.find_by(name: "mnr")._id.to_s
      Line.create(name: "Hudson", query: "status_as_class((feed.xpath('//status')[41]).to_s[8...-9])", status: "a", service_id: mnr)
      Line.create(name: "Harlem", query: "status_as_class((feed.xpath('//status')[42]).to_s[8...-9])", status: "a", service_id: mnr)
      Line.create(name: "New Haven", query: "status_as_class((feed.xpath('//status')[44]).to_s[8...-9])", status: "a", service_id: mnr)
    end

    unless Line.where(name: "Babylon", service_id: !0).any?
      # LIRR
      puts "Creating LIRR line records..."
      lirr = Service.find_by(name: "lirr")._id.to_s
      Line.create(name: "Babylon", query: "status_as_class((feed.xpath('//status')[30]).to_s[8...-9])", status: "a", service_id: lirr)
      Line.create(name: "Far Rockaway", query: "status_as_class((feed.xpath('//status')[32]).to_s[8...-9])", status: "a", service_id: lirr)
      Line.create(name: "Hempstead", query: "status_as_class((feed.xpath('//status')[33]).to_s[8...-9])", status: "a", service_id: lirr)
      Line.create(name: "Long Beach", query: "status_as_class((feed.xpath('//status')[34]).to_s[8...-9])", status: "a", service_id: lirr)
      Line.create(name: "Montauk", query: "status_as_class((feed.xpath('//status')[35]).to_s[8...-9])", status: "a", service_id: lirr)
      Line.create(name: "Oyster Bay", query: "status_as_class((feed.xpath('//status')[36]).to_s[8...-9])", status: "a", service_id: lirr)
      Line.create(name: "Pt Jefferson", query: "status_as_class((feed.xpath('//status')[37]).to_s[8...-9])", status: "a", service_id: lirr)
      Line.create(name: "Pt Washington", query: "status_as_class((feed.xpath('//status')[38]).to_s[8...-9])", status: "a", service_id: lirr)
      Line.create(name: "Ronkonkoma", query: "status_as_class((feed.xpath('//status')[39]).to_s[8...-9])", status: "a", service_id: lirr)
      Line.create(name: "W Hempstead", query: "status_as_class((feed.xpath('//status')[40]).to_s[8...-9])", status: "a", service_id: lirr)
    end
    puts "Done!"
  end
end

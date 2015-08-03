require "bundler/setup"
require "sinatra"
require "nokogiri"
require "httparty"
require "pry" if development?
require "sinatra/reloader" if development?

Dir.glob(File.join("helpers", "**", "*.rb")).each do |helper|
  require_relative helper
end

# Mongo Setup
require 'mongoid'
require_relative File.join("db/models.rb")
Mongoid.load!("db/mongoid.yml", ENV["RACK_ENV"])

get "/" do
  feed = Nokogiri::XML.parse(HTTParty.get("http://web.mta.info/status/serviceStatus.txt"))

  @subway_statuses = Line.where(service_id: Service.find_by(name: "nyct")._id).collect do |lines|
    lines.name.split(//).map do |line|
      line_status(line, lines.name, feed)
    end
  end.flatten

  @mnr_statuses = Line.where(service_id: Service.find_by(name: "mnr")._id)

  @lirr_statuses = Line.where(service_id: Service.find_by(name: "lirr")._id)

  erb :index
end

get '/:service' do
  feed = Nokogiri::XML.parse(HTTParty.get("http://web.mta.info/status/serviceStatus.txt"))
  service = params[:service].downcase

  if Service.where(name: service)
    if service == "subway"
      @service_heading = service.capitalize
      @service_prefix = "nyct"
      @subway_statuses = Line.where(service_id: Service.find_by(name: "nyct")._id).collect do |lines|
        lines.name.split(//).map do |line|
          line_status(line, lines.name, feed)
        end
      end.flatten

    elsif service == "lirr"
      @service_heading = service.upcase
      @service_prefix = service
      @custom_statuses = Line.where(service_id: Service.find_by(name: "lirr")._id).each do |line|
        line.update_attributes(status: eval(line.query))
      end

    elsif service == "mnr"
      @service_heading = "Metro-North"
      @service_prefix = @service_heading.downcase
      @custom_statuses = Line.where(service_id: Service.find_by(name: "mnr")._id).each do |line|
        line.update_attributes(status: eval(line.query))
      end
    end
    erb :custom
  else
    render text: "404"
  end
end

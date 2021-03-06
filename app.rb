require "bundler/setup"
require "sinatra"
require "nokogiri"
require "httparty"
require "json"

if development?
  require "pry"
  require "sinatra/reloader"
  require 'rack-mini-profiler'
  require 'flamegraph'
  require 'stackprof'
  require 'memory_profiler'
  use Rack::MiniProfiler
  Rack::MiniProfiler.config.position = 'right'
end

Dir.glob(File.join("helpers", "**", "*.rb")).each do |helper|
  require_relative helper
end

# Mongo Setup
require 'mongoid'
require_relative File.join("db/models.rb")
Mongoid.load!("db/mongoid.yml", ENV["RACK_ENV"])

def feed
  @feed ||= Nokogiri::XML.parse(Feed.last.payload)
end

get "/" do
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
      @custom_statuses = Line.where(service_id: Service.find_by(name: "nyct")._id).collect do |lines|
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

get '/api/status.json' do
  content_type :json
  feed = Nokogiri::XML.parse(HTTParty.get("http://web.mta.info/status/serviceStatus.txt"))

  @subway_statuses = Line.where(service_id: Service.find_by(name: "nyct")._id).collect do |lines|
    lines.name.split(//).map do |line|
      line_status(line, lines.name, feed)
    end
  end.flatten

  @lirr_statuses = Line.where(service_id: Service.find_by(name: "lirr")._id).each do |line|
    line.update_attributes(status: eval(line.query))
  end

  @mnr_statuses = Line.where(service_id: Service.find_by(name: "mnr")._id).each do |line|
    line.update_attributes(status: eval(line.query))
  end

  {:nyct_lines => @subway_statuses, :lirr_lines => @lirr_statuses, :mnr_lines => @mnr_statuses}.to_json
end

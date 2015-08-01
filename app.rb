require "bundler/setup"
require "sinatra"
require "nokogiri"
require "httparty"
require "pry" if development?
require "sinatra/reloader" if development?
require "sequel"

DB = Sequel.connect(ENV["DATABASE_URL"] || "postgres:///nyc_development")

Dir.glob(File.join("models", "**", "*.rb")).each do |model|
  require_relative model
end

Dir.glob(File.join("helpers", "**", "*.rb")).each do |helper|
  require_relative helper
end

MTA_SUBWAY_LINES = ["ACE", "BDFM", "G", "JZ", "L", "NQR", "S", "123", "456", "7"].to_a

get "/" do
  feed = Nokogiri::XML.parse(HTTParty.get("http://web.mta.info/status/serviceStatus.txt"))

  @subway_statuses = MTA_SUBWAY_LINES.collect do |lines|
    lines.split(//).map do |line|
      line_status(line, lines, feed)
    end
  end.flatten

  @mnr_statuses = [
    {:name=>"Hudson", :status=> "#{status_as_class((feed.xpath('//status')[41]).to_s[8...-9])}"},
    {:name=>"Harlem", :status=> "#{status_as_class((feed.xpath('//status')[42]).to_s[8...-9])}"},
    {:name=>"New Haven", :status=> "#{status_as_class((feed.xpath('//status')[44]).to_s[8...-9])}"},
  ]

  @lirr_statuses = [
    {:name=>"Babylon", :status=> "#{status_as_class((feed.xpath('//status')[30]).to_s[8...-9])}"},
    {:name=>"Far Rockaway", :status=> "#{status_as_class((feed.xpath('//status')[32]).to_s[8...-9])}"},
    {:name=>"Hempstead", :status=> "#{status_as_class((feed.xpath('//status')[33]).to_s[8...-9])}"},
    {:name=>"Long Beach", :status=> "#{status_as_class((feed.xpath('//status')[34]).to_s[8...-9])}"},
    {:name=>"Montauk", :status=> "#{status_as_class((feed.xpath('//status')[35]).to_s[8...-9])}"},
    {:name=>"Oyster Bay", :status=> "#{status_as_class((feed.xpath('//status')[36]).to_s[8...-9])}"},
    {:name=>"Pt Jefferson", :status=> "#{status_as_class((feed.xpath('//status')[37]).to_s[8...-9])}"},
    {:name=>"Pt Washington", :status=> "#{status_as_class((feed.xpath('//status')[38]).to_s[8...-9])}"},
    {:name=>"Ronkonkoma", :status=> "#{status_as_class((feed.xpath('//status')[39]).to_s[8...-9])}"},
    {:name=>"W Hempstead", :status=> "#{status_as_class((feed.xpath('//status')[40]).to_s[8...-9])}"}
  ]

  erb :index
end

get '/:service' do
  feed = Nokogiri::XML.parse(HTTParty.get("http://web.mta.info/status/serviceStatus.txt"))

  SERVICES = ["subway", "lirr", "mnr"].to_a
  if SERVICES.include?(params[:service])
    puts "#{params[:service]}"
    if params[:service] == "subway"
      @service_heading = "Subway"
      @service_prefix = "nyct"
      @custom_statuses = MTA_SUBWAY_LINES.collect do |lines|
        lines.split(//).map do |line|
          line_status(line, lines, feed)
        end
      end.flatten

    elsif params[:service] == "lirr"
      @service_heading = "LIRR"
      @service_prefix = "lirr"
      @custom_statuses = [
        {:name=>"Babylon", :status=> "#{status_as_class((feed.xpath('//status')[30]).to_s[8...-9])}"},
        {:name=>"Far Rockaway", :status=> "#{status_as_class((feed.xpath('//status')[32]).to_s[8...-9])}"},
        {:name=>"Hempstead", :status=> "#{status_as_class((feed.xpath('//status')[33]).to_s[8...-9])}"},
        {:name=>"Long Beach", :status=> "#{status_as_class((feed.xpath('//status')[34]).to_s[8...-9])}"},
        {:name=>"Montauk", :status=> "#{status_as_class((feed.xpath('//status')[35]).to_s[8...-9])}"},
        {:name=>"Oyster Bay", :status=> "#{status_as_class((feed.xpath('//status')[36]).to_s[8...-9])}"},
        {:name=>"Pt Jefferson", :status=> "#{status_as_class((feed.xpath('//status')[37]).to_s[8...-9])}"},
        {:name=>"Pt Washington", :status=> "#{status_as_class((feed.xpath('//status')[38]).to_s[8...-9])}"},
        {:name=>"Ronkonkoma", :status=> "#{status_as_class((feed.xpath('//status')[39]).to_s[8...-9])}"},
        {:name=>"W Hempstead", :status=> "#{status_as_class((feed.xpath('//status')[40]).to_s[8...-9])}"}
      ]

    elsif params[:service] == "mnr"
      @service_heading = "Metro-North"
      @service_prefix = "metro-north"
      @custom_statuses = [
        {:name=>"Hudson", :status=> "#{status_as_class((feed.xpath('//status')[41]).to_s[8...-9])}"},
        {:name=>"Harlem", :status=> "#{status_as_class((feed.xpath('//status')[42]).to_s[8...-9])}"},
        {:name=>"New Haven", :status=> "#{status_as_class((feed.xpath('//status')[44]).to_s[8...-9])}"},
      ]
    end
    erb :custom
  else
    render text: "404"
  end
end

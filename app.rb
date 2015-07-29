require "bundler/setup"
require "sinatra"
require "nokogiri"
require "httparty"
require "pry" if development?
require "sinatra/reloader" if development?

Dir.glob(File.join("helpers", "**", "*.rb")).each do |helper|
  require_relative helper
end

MTA_SUBWAY_LINES = ["ACE", "BDFM", "G", "JZ", "L", "NQR", "S", "123", "456", "7"].to_a
MTA_LIRR_LINES = ["Far Rockaway", "Babylon"].to_a

get "/" do
  feed = Nokogiri::XML.parse(HTTParty.get("http://web.mta.info/status/serviceStatus.txt"))

  def status_as_class(description)
    case description.downcase
    when 'good service' then 'online'
    when 'delays' then 'delays'
    when 'service change' then 'delays'
    when 'planned work' then 'delays'
    else 'offline'
    end
  end

  def line_status(line, in_lines, feed)
    line_status = feed
      .css("line:contains(#{in_lines})")
      .find {|line| line.css('name').text.chomp == in_lines}
    status = line_status.css('status').text.chomp
    {name: line, status: status_as_class(status)}
  end

  @subway_line_statuses = MTA_SUBWAY_LINES.collect do |lines|
    lines.split(//).map do |line|
      line_status(line, lines, feed)
    end
  end.flatten

  @lirr_statuses = [
    {:name=>"Babylon", :status=> "#{status_as_class((feed.xpath('//status')[30]).to_s[8...-9])}"},
    {:name=>"City Terminal", :status=> "#{status_as_class((feed.xpath('//status')[31]).to_s[8...-9])}"},
    {:name=>"Far Rockaway", :status=> "#{status_as_class((feed.xpath('//status')[32]).to_s[8...-9])}"},
    {:name=>"Hempstead", :status=> "#{status_as_class((feed.xpath('//status')[33]).to_s[8...-9])}"},
    {:name=>"Long Beach", :status=> "#{status_as_class((feed.xpath('//status')[34]).to_s[8...-9])}"},
    {:name=>"Montauk", :status=> "#{status_as_class((feed.xpath('//status')[35]).to_s[8...-9])}"},
    {:name=>"Oyster Bay", :status=> "#{status_as_class((feed.xpath('//status')[36]).to_s[8...-9])}"},
    {:name=>"Port Jefferson", :status=> "#{status_as_class((feed.xpath('//status')[37]).to_s[8...-9])}"},
    {:name=>"Port Washington", :status=> "#{status_as_class((feed.xpath('//status')[38]).to_s[8...-9])}"},
    {:name=>"Ronkonkoma", :status=> "#{status_as_class((feed.xpath('//status')[39]).to_s[8...-9])}"},
    {:name=>"West Hempstead", :status=> "#{status_as_class((feed.xpath('//status')[40]).to_s[8...-9])}"}
  ]

  erb :index
end

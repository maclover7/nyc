require "bundler/setup"
require "sinatra"
require "nokogiri"
require "httparty"
require "pry" if development?
require "sinatra/reloader" if development?

Dir.glob(File.join("helpers", "**", "*.rb")).each do |helper|
  require_relative helper
end

MTA_LETTER_SUBWAY_LINES = ["ACE", "BDFM", "G", "JZ", "L", "NQR", "S"].to_a
MTA_NUMBER_SUBWAY_LINES = ["123", "456", "7"].to_a

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

  @letter_line_statuses = MTA_LETTER_SUBWAY_LINES.collect do |lines|
    lines.split(//).map do |line|
      line_status(line, lines, feed)
    end
  end.flatten

  @number_line_statuses = MTA_NUMBER_SUBWAY_LINES.collect do |lines|
    lines.split(//).map do |line|
      line_status(line, lines, feed)
    end
  end.flatten

  erb :index
end

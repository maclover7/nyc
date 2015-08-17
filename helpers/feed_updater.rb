require 'rufus-scheduler'
require 'nokogiri'
require 'httparty'

scheduler = Rufus::Scheduler.new

scheduler.every '2m' do
  mongo_feed = Feed.last
  mta_feed = HTTParty.get("http://web.mta.info/status/serviceStatus.txt")
  mongo_feed.update_attributes(payload: mta_feed, fetched_at: Time.now)
  puts "reloaded MTA feed!"
end

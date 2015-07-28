require "bundler/setup"
require "sinatra"
require "sinatra/reloader" if development?

Dir.glob(File.join("helpers", "**", "*.rb")).each do |helper|
  require_relative helper
end

get "/" do
  erb :index
end

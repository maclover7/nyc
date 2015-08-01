require "rake/testtask"
require "sequel"

# Import any external rake tasks
Dir.glob('tasks/*.rake').each { |r| import r }

namespace :db do
  desc "Initialize Database"
  task :setup do
    DB = Sequel.connect(ENV["DATABASE_URL"] || "postgres:///nyc_development")
    unless DB[:services].where(name: "nyct").any?
      puts "Creating records..."
      DB[:services].insert(name: "nyct")
      DB[:services].insert(name: "lirr")
      DB[:services].insert(name: "mnr")
    end
    puts "Done!"
  end
end

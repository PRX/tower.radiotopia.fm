require './app'

if memcachier_servers = ENV['MEMCACHIER_SERVERS']
  cache = Dalli::Client.new memcachier_servers.split(','), {
    username: ENV['MEMCACHIER_USERNAME'],
    password: ENV['MEMCACHIER_PASSWORD']
  }
  use Rack::Cache, verbose: true, metastore: cache, entitystore: cache
end

register Sinatra::CrossOrigin

run App

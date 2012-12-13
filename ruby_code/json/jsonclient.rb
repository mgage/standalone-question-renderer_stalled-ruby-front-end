require 'rubygems'
require 'rpcjson'

# 1.1 is required because bitcoind does not speak 2.0
bc = RPC::JSON::Client.new 'http://username:password@127.0.0.1:8332', 1.1

# JSON-RPC error objects are raised as Ruby objects of the type
# RPC::JSON::Client::Error. The original object is available at
# e.error

begin

  # First get server info
  puts "Getting server information..."
  info = bc.getinfo
  info.each_key do |key|
    puts "#{key}: #{info[key]}"
  end

  # Will raise error
  puts "Shutting down the server..."
  bc.st0p
rescue RPC::JSON::Client::Error => e
  puts "Got an error: #{e}: #{e.error.to_json}"
end
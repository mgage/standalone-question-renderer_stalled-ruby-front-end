#!/usr/bin/env ruby

# 
# Install XML-RPC
#

require "rbconfig"
require "ftools"

INST = [ 
{
  :srcpath => "lib",
  :dstpath => Config::CONFIG["sitelibdir"] + "/" + "xmlrpc",
  :files   => %w(base64.rb client.rb config.rb create.rb datetime.rb httpserver.rb marshal.rb parser.rb server.rb utils.rb)
}, 
{
  :srcpath => "redist",
  :dstpath => Config::CONFIG["sitelibdir"],
  :files   => %w(GServer.rb TCPSocketPipe.rb application.rb dump.rb) 
} 
]

begin
  for inst in INST
    File.mkpath inst[:dstpath], true
    for name in inst[:files]
      File.install "#{ inst[:srcpath] }/#{name}", "#{ inst[:dstpath] }/#{name}", 0644, true   
    end
  end
  
rescue 
  puts "install failed!"
  puts $!
else
  puts "install succeed!"
end

require "webrick"
require "xmlrpc/server"

s = XMLRPC::WEBrickServlet.new
s.add_handler("michael.add") do |a,b|
  a + b
end
s.add_handler("michael.div") do |a,b|
  if b == 0
    raise XMLRPC::FaultException.new(1, "division by zero")
  else
    a / b 
  end
end 

s.set_default_handler do |name, *args|
  raise XMLRPC::FaultException.new(-99, "Method #{name} missing" +
        " or wrong number of parameters!")
end

s.add_introspection

httpserver = WEBrick::HTTPServer.new(:Port => 8080)    
httpserver.mount("RPC2", s)
trap("HUP") { httpserver.shutdown }   # use 1 instead of "HUP" on Windows
httpserver.start

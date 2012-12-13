require "xmlrpc/client"
 
server = XMLRPC::Client.new("localhost", "/RPC2", 8080)

ok, param = server.call2("michael.add", 4, 5)
if ok then
  puts "4 + 5 = #{param}"
else
  puts "Error:"
  puts param.faultCode 
  puts param.faultString
end

p server.call("system.listMethods")

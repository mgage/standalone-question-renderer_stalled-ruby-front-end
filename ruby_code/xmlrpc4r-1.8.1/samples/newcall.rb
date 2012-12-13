#!/usr/bin/env ruby

require "xmlrpc/client"
require "pp"

#server = XMLRPC::Client.new("localhost", "/cgi-bin/xml.cgi", 80)
#server = XMLRPC::Client.new2("http://michael:neumann@localhost:8070/cgi-bin/xml.cgi")
#server = XMLRPC::Client.new("localhost", "/cgi-bin/xml.fcgi", 80)
#server = XMLRPC::Client.new2("http://www.advogato.org/XMLRPC")
server = XMLRPC::Client.new2("https://hosted2.webwork.rochester.edu/mod_xmlrpc/")
# ok, param = server.call2("test.sumprod",2,1)
 ok, param = server.call2("WebworkXMLRPC.hi")

if ok then
  print "4 + 5 = " 
  pp param
else
  puts "Error:"
  puts param.faultCode 
  puts param.faultString
end

#p server.call("test.listMethods")

#http://www.advogato.org/xmlrpc.html

#!/usr/bin/env ruby

require "xmlrpc/client"
 
server = XMLRPC::Client.new("localhost", "/RPC2", 8070)

server.call("system.listMethods").each do |m|
  p m
  p server.call("system.methodSignature", m)
  p server.call("system.methodHelp", m)
  puts "---------------"
end


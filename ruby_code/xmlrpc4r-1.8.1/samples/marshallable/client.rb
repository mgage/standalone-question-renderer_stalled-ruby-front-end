#!/usr/bin/env ruby

require "xmlrpc/client"
require "person"

server = XMLRPC::Client.new("localhost", "/RPC2", 8070)
p server.call("test.person") 

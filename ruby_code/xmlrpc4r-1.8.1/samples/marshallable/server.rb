#!/usr/bin/env ruby

require "xmlrpc/server"
require "person"

s = XMLRPC::Server.new(8070)

s.add_handler("test.person") {
  Person.new("Michael", 21)
}
s.serve


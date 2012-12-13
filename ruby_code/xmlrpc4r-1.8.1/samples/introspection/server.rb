#!/usr/bin/env ruby


require "xmlrpc/server"

s = XMLRPC::Server.new(8070)    # if you want a standalone server

s.add_handler("michael.add", %w(int int int), "adds two integers") {|a,b|
  a+b
}  
s.add_handler("michael.div", [%w(int int int), %w(double double double)], "divides two numbers") {|a,b|
  if b == 0
    raise XMLRPC::FaultException.new 1, "division by zero"
  else
    a / b
  end
}

s.add_introspection

s.serve


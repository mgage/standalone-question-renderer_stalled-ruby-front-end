#!/usr/bin/env ruby

require "xmlrpc/server"


IMyHandlerClass = XMLRPC::interface("michael") {
  meth "int sub(int, int)", "Subtracts two integers"
  meth "int add(int, int)", "Adds two integers"
  meth "double exp(double, double)", "Exponent", :exp 
}

class MyHandlerClass
  def add(a,b)
    a+b
  end

  def sub(a,b)
    a-b
  end

  def exp(a,b)
    a ** b
  end
end
 

s = XMLRPC::Server.new(8070, "127.0.0.1", 4, nil, true, true)    # if you want a standalone server

s.add_handler(IMyHandlerClass, MyHandlerClass.new)

s.add_multicall
s.add_introspection

s.serve


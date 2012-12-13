#!/usr/bin/env ruby


require "xmlrpc/server"


class MyHandlerClass

  def sub(a,b)
    a-b
  end

  def exp(a,b)
    a ** b
  end
  
end
 

s = XMLRPC::Server.new(8080, "127.0.0.1", 4, nil, true, true)    # if you want a standalone server
#s = XMLRPC::CGIServer.new

s.add_handler("michael.add") {|a,b|
  a+b
}  
s.add_handler("michael.div") {|a,b|
  if b == 0
    raise XMLRPC::FaultException.new 1, "division by zero"
  else
    a / b
  end
}

#s.add_handler("michael", MyHandlerClass.new)
s.add_handler(XMLRPC::iPIMethods("michael"), MyHandlerClass.new)

s.add_multicall
s.add_introspection

s.serve


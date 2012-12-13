=begin
= xmlrpc4r - HOWTO
Copyright (C) 2001, 2002, 2003 by Michael Neumann (mneumann@ntecs.de)

Released under the same term of license as Ruby.

= Install
You can currently use xmlrpc4r with two parsers, XMLParser and/or NQXML.
Both are available at RAA (Ruby Application Archive - ((<URL:http://raa.ruby-lang.org/>))).

If you want to use XMLParser (Expat Module for Ruby), you have to install  
James Clark's XML Parser Toolkit "expat". I recommend using XMLParser, 
because xmlrpc4r is better tested with it and XMLParser is much faster than NQXML.
The advantage of using NQXML is that it is written in pure Ruby.

Then you'll need "xmlrpc4r" of course, which is available at
((<URL:http://www.ntecs.de/projects/xmlrpc4r>)).

To install xmlrpc4r:
  tar -xvzf xmlrpc4r-1_7_12.tar.gz
  cd xmlrpc4r-1_7_12
  su root -c "ruby install.rb"


= Samples

== Client

  require "xmlrpc/client"
  
  # Make an object to represent the XML-RPC server.
  server = XMLRPC::Client.new( "xmlrpc-c.sourceforge.net", "/api/sample.php")

  # Call the remote server and get our result
  result = server.call("sample.sumAndDifference", 5, 3)

  sum = result["sum"]
  difference = result["difference"]

  puts "Sum: #{sum}, Difference: #{difference}"

== Client with XML-RPC fault-structure handling

There are two possible ways, of handling a fault-structure:

=== by catching a XMLRPC::FaultException exception 

  require "xmlrpc/client"

  # Make an object to represent the XML-RPC server.
  server = XMLRPC::Client.new( "xmlrpc-c.sourceforge.net", "/api/sample.php")

  begin
    # Call the remote server and get our result
    result = server.call("sample.sumAndDifference", 5, 3)

    sum = result["sum"]
    difference = result["difference"]

    puts "Sum: #{sum}, Difference: #{difference}"

  rescue XMLRPC::FaultException => e
    puts "Error: "
    puts e.faultCode
    puts e.faultString
  end
   
=== by calling "call2" which returns a boolean

  require "xmlrpc/client"

  # Make an object to represent the XML-RPC server.
  server = XMLRPC::Client.new( "xmlrpc-c.sourceforge.net", "/api/sample.php")

  # Call the remote server and get our result
  ok, result = server.call2("sample.sumAndDifference", 5, 3)

  if ok
    sum = result["sum"]
    difference = result["difference"]

    puts "Sum: #{sum}, Difference: #{difference}"
  else
    puts "Error: "
    puts result.faultCode
    puts result.faultString
  end
   
== Client using Proxy

You can create a (({Proxy})) object onto which you can call methods. This way it
looks nicer. Both forms, "call" and "call2" are supported through "proxy" and "proxy2".
You can additionally give arguments to the Proxy, which will be given to each XML-RPC
call using that Proxy.

  require "xmlrpc/client"
  
  # Make an object to represent the XML-RPC server.
  server = XMLRPC::Client.new( "xmlrpc-c.sourceforge.net", "/api/sample.php")

  # Create a Proxy object
  sample = server.proxy("sample")

  # Call the remote server and get our result
  result = sample.sumAndDifference(5,3)

  sum = result["sum"]
  difference = result["difference"]

  puts "Sum: #{sum}, Difference: #{difference}"



== CGI-based Server

There are also two ways to define handler, the first is
like C/PHP, the second like Java, of course both ways
can be mixed:

=== C/PHP-like (handler functions)

  require "xmlrpc/server"

  s = XMLRPC::CGIServer.new

  s.add_handler("sample.sumAndDifference") do |a,b|
    { "sum" => a + b, "difference" => a - b }
  end
    
  s.serve

=== Java-like (handler classes)

  require "xmlrpc/server"

  s = XMLRPC::CGIServer.new

  class MyHandler
    def sumAndDifference(a, b)
      { "sum" => a + b, "difference" => a - b }
    end
  end
    
  # NOTE: Security Hole (read below)!!! 
  s.add_handler("sample", MyHandler.new)
  s.serve


To return a fault-structure you have to raise an FaultException e.g.:
  raise XMLRPC::FaultException.new(3, "division by Zero")

==== Security Note

From Brian Candler:

  Above code sample has an extremely nasty security hole, in that you can now call                                                        
  any method of 'MyHandler' remotely, including methods inherited from Object                                                        
  and Kernel! For example, in the client code, you can use                                                                           
                                                                                                                                   
    puts server.call("sample.send","`","ls")                                                                                       
                                                                                                                                   
  (backtick being the method name for running system processes). Needless to                                                         
  say, 'ls' can be replaced with something else.                                                                                     

  The version which binds proc objects (or the version presented below in the next section) 
  doesn't have this problem, but people may be tempted to use the second version because it's 
  so nice and 'Rubyesque'. I think it needs a big red disclaimer.


From Michael:

A solution is to undef insecure methods or to use (({XMLRPC::iPIMethods})) as shown below:

  class MyHandler
    def sumAndDifference(a, b)
      { "sum" => a + b, "difference" => a - b }
    end
  end

  # ... server initialization ...

  s.add_handler(XMLRPC::iPIMethods("sample"), MyHandler.new)

  # ...

This adds only public instance methods explicitly declared in class MyHandler 
(and not those inherited from any other class).

=== With interface declarations

Code sample from the book Ruby Developer's Guide:

  require "xmlrpc/server"

  class Num
    INTERFACE = XMLRPC::interface("num") {
      meth 'int add(int, int)', 'Add two numbers', 'add'
      meth 'int div(int, int)', 'Divide two numbers'
    }

    def add(a, b) a + b end
    def div(a, b) a / b end
  end


  s = XMLRPC::CGIServer.new
  s.add_handler(Num::INTERFACE, Num.new)
  s.serve



== Standalone server

Same as CGI-based server, only that the line
  server = XMLRPC::CGIServer.new
must be changed to
  server = XMLRPC::Server.new(8080)
if you want a server listening on port 8080.
The rest is the same.

== Choosing a different XML Parser or XML Writer
The examples above all use the default parser (which is now since 1.6.9 NQXMLParser)
and a default XML writer.
If you want to use XMLParser or XMLStreamParser, then you have to call the (({#set_parser})) 
method onto (({XMLRPC::Client})) instances or instances of subclasses of (({XMLRPC::BasicServer})) 
or by editing lib/config.rb.

Client Example:
 
  # ...
  server = XMLRPC::Client.new( "xmlrpc-c.sourceforge.net", "/api/sample.php")
  server.set_parser(XMLRPC::XMLParser::XMLParser.new)
  # ...

Server Example:

  # ...
  s = XMLRPC::CGIServer.new
  s.set_parser(XMLRPC::XMLParser::XMLStreamParser.new)
  # ...
  
or:

  # ...
  server = XMLRPC::Server.new(8080)
  server.set_parser(XMLRPC::XMLParser::NQXMLParser.new)
  # ...


Note that XMLStreamParser is incredible faster (and uses less memory) than XMLTreeParser, NQXMLStreamParser or 
NQXMLTreeParser, and scales well for large documents. For example for a 0.5 MB XML document with many tags,
XMLStreamParser is ~350 (!) times faster than NQXMLTreeParser and still ~18 times as fast as 
XMLTreeParser.

You can change the XML Writer by calling (({#set_writer})).

  Much easier is (when using xmlrpc4r version > 1.6.3) to change
  the file xmlrpc/config.rb and change there the settings which
  XML parser/writer to use.  

=end


#!/usr/bin/perl -w

#
use XMLRPC::Lite;
  my $soap = XMLRPC::Lite
   # -> proxy('https://math.webwork.rochester.edu/mod_xmlrpc/');
   #-> proxy('https://devel.webwork.rochester.edu:8002/mod_xmlrpc/');
   # -> proxy('http://localhost/mod_xmlrpc/');
   #  -> proxy('http://hosted2.webwork.rochester.edu/mod_xmlrpc/');
      -> proxy('http://127.0.0.1:1234');
  
	
  my $result = $soap->call("WebworkXMLRPC.hi");
  
  unless ($result->fault) {
    print $result->result(),"\n";
  } else {
    print join ', ',
      $result->faultcode,
      $result->faultstring;
  }

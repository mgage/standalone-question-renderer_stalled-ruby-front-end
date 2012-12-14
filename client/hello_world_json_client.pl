#!/usr/bin/perl -w


 use JSON::RPC::Client;

  
    my $client = new JSON::RPC::Client;
#   my $url    = 'http://www.example.com/jsonrpc/API';
#   my $uri    = 'http://date.jsontest.com/';
    my $uri    = 'http://127.0.0.1:1234';
   
   my $callobj = {
      method  => 'WebworkXMLRPC.hi',
      params  => [ 17, 25 ], # ex.) params => { a => 20, b => 10 } for JSON-RPC v1.1
   };
   
   my $res = $client->call($uri, $callobj);

  
   if($res) {
      if ($res->is_error) {
          print "Error : ", $res->error_message;
      }
      else {
          print $res->result;
      }
   }
   else {
      print $client->status_line;
   }
   
   
   # Easy access
   
  # $client->prepare($uri, ['sum', 'echo']);
  # print $client->sum(10, 23);
   
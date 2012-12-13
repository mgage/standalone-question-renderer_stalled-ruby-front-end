#!/usr/bin/env ruby

require "xmlrpc/client"
require "thread"
 
server = XMLRPC::Client.new2("http://michael:neumann@localhost/cgi-bin/xml.cgi")

start = Time.now

thr = []
10.times do
  thr << Thread.new {
    ok, param = server.call2_async("michael.add", 4, 5)
    p param
  }
end
thr.each {|t| t.join}
end1 = Time.now


10.times do 
  ok, param = server.call2("michael.add", 4, 5)
  p param
end


end2 = Time.now

puts 
puts

p (end1-start).to_i
p (end2-end1).to_i



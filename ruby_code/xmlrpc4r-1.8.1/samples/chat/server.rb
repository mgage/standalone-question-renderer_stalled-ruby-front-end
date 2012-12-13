#!/usr/bin/env ruby

#
# The multicast server
# 
# Copyright (C) 2001 by Michael Neumann (mneumann@ntecs.de)
#

require "xmlrpc/client"
require "xmlrpc/server"


class ChatServer

  def initialize
    @channel = {}
  end

  def connect(channel, host, port)
    rpc_path = [host, port]
    key = channel.to_s
    @channel[key] ||= []
    @channel[key] << rpc_path
  end

  def disconnect(channel, host, port)
    rpc_path = [host, port]
    arr = @channel[channel.to_s]
    arr.delete(rpc_path) if arr
  end

  def send(channel, message)
    arr = @channel[channel.to_s]
    return false if arr.nil?

    arr.each do |host, port|
      server = XMLRPC::Client.new(host, "/RPC2", port)
      server.call2("chat.client.message", channel, message)
    end

    true
  end
 
end

if $0 == __FILE__
  port = ARGV[0] || 7000
  s = XMLRPC::Server.new(port.to_i)
  s.add_handler("chat.server", ChatServer.new)
  s.serve
end


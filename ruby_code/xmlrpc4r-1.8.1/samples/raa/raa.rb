#!/usr/bin/env ruby

#
# This library provides access to the XML-RPC interface
# of RAA (Ruby Application Archive)
#

require "xmlrpc/client"

class RAA

  def initialize(host, path, port=80)
    @server = XMLRPC::Client.new(host, path, port)
    @raa = @server.proxy("raa")
  end

  def getAllListings
    @raa.getAllListings
  end

  def getProductTree
    @raa.getProductTree
  end

  def getInfoFromCategory(major, minor)
    @raa.getInfoFromCategory(:major =>  major, :minor => minor)  
  end

  def getModifiedInfoSince(time)
    @raa.getModifiedInfoSince(time)
  end

  def getInfoFromName(name)
    @raa.getInfoFromName(name)
  end

end



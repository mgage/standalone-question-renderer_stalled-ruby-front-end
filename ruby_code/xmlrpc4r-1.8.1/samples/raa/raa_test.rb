#!/usr/bin/env ruby

#
# This sample demonstrates how to call the XML-RPC interface
# of RAA (Ruby Application Archive)
#

require "raa"

raa = RAA.new("www.ruby-lang.org", "/~nahi/xmlrpc/raa/")


#
# Returns an array of all names (strings) 
# of the packages at RAA
#
p raa.getAllListings


#
# Returns a hash, containing the main sections of RAA as keys
# (Application, Library, Documentation, Ports...) and the
# corresponding values are also hashs which values are
# the subsections, the values are arrays containing the
# names of the packages under this section.
#
p raa.getProductTree


#
# Returns an array of hashes, where each hash
# describes completely a RAA package.
# Only packages in section "Library" and subsection
# "XML" are returned.
#
p raa.getInfoFromCategory( "Library", "XML" )


#
# The package which name is "XML-RPC" is returned as a
# hash containing all the info of that package (same as above).
#
p raa.getInfoFromName( "XML-RPC" )


#
# Get all packages (in an array) which has been
# modified since the given time.
#
p raa.getModifiedInfoSince( Time.at( Time.now.to_i - 24 * 3600 ) )



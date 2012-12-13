#! /usr/bin/env ruby

# Benchmark for Parser
# 
# Copyright (C) 2001 by Michael Neumann (mneumann@ntecs.de)
#

require "xmlrpc/parser"
require "xmlrpc/server"
require "benchmark"    
include Benchmark

def create_middle
  XMLRPC::Create.new.methodCall(
    "test", 
    (1..100).to_a, 
    ("hallo".."halpo").to_a
  )
end

def rec_struct(width, value, n)
  return value if n == 0
  x = []
  width.times { x << rec_struct(width, value, n-1) }
  x
end

def create_huge
  XMLRPC::Create.new.methodResponse(true,
   rec_struct(5, {"name" => 4343, "value" => "halkjkjk"}, 5)  
 )
end

def create_base64(size)
  XMLRPC::Create.new.methodResponse(true, XMLRPC::Base64.new("T" * size))
end


FILES = {
  "small"   => [:call, File.readlines("files/value.xml").to_s],
  "middle"  => [:call, create_middle],
  "large"   => [:response, File.readlines("files/xml1.xml").to_s],
  "huge"    => [:response, create_huge, 1],
  "base64"  => [:response, create_base64(1024*1024)]
}

PARSER = {
  "XMLTreeParser"       => XMLRPC::XMLParser::XMLTreeParser.new,
  "NQXMLTreeParser"     => XMLRPC::XMLParser::NQXMLTreeParser.new,

  "XMLStreamParser"     => XMLRPC::XMLParser::XMLStreamParser.new,
  "NQXMLStreamParser"   => XMLRPC::XMLParser::NQXMLStreamParser.new
}

N = 50 

bm(40) do |test|
  PARSER.each do |name, parser|
    FILES.each do |file, data|
      GC.start

      test.report("#{name} - #{file} (#{data[1].size} bytes)") do
        if data[0] == :call
          (data[2] || N).times { parser.parseMethodCall(data[1]) }
        elsif data[0] == :response
          (data[2] || N).times { parser.parseMethodResponse(data[1]) }
        end
      end

    end
  end
end


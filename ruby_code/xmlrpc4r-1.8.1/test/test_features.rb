#
# Testcase for parser Features
# 
# Copyright (C) 2001, 2002 by Michael Neumann (mneumann@ntecs.de)
#

require "./util"
require "xmlrpc/create"
require "xmlrpc/parser"
require "xmlrpc/config"

module XMLRPC
module Config
  ENABLE_NIL_CREATE = true
  ENABLE_NIL_PARSER = true
end
end

class Test_Features < Test::Unit::TestCase

  def setup
    @c = [ XMLRPC::Create.new(XMLRPC::XMLWriter::Simple.new),
           XMLRPC::Create.new(XMLRPC::XMLWriter::XMLParser.new) ]

    @p = XMLRPC::XMLParser::Classes.map {|klass| klass.new} 
  end

  def test_nil
    params = [nil, {"test" => nil}, [nil, 1, nil]]

    @c.each do |c| 
      str = c.methodCall("test", *params) 
      @p.each do |p|
        para = p.parseMethodCall(str)
        assert_equal(para[1], params)
      end
    end
  end

end

$suite << Test_Features.suite

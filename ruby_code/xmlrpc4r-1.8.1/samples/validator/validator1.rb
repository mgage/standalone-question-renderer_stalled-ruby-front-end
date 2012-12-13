#! /usr/bin/env ruby

#
# An implementation of tests for the the first validator suite
# (validator1) as shown on http://www.xmlrpc.com/validator1Docs 
# For validated hosts, see http://validator.xmlrpc.com where
# 149.225.142.138, 149.225.145.228, 149.225.114.66 (all NetBSD) and
# 149.225.117.236 (Windows 98) were my hosts.
# 
# Copyright (C) 2001 by Michael Neumann (mneumann@ntecs.de)
#


class Validator1

  #
  # Takes single parameter, array of structs, where
  # each structure has at least the three elements
  # "moe", "larry" and "curly" which are all integers.
  # Had to return the sum of all struct-elements named
  # "curly". 
  #
  def arrayOfStructsTest(arr)
    sum = 0
    arr.each do |struc|
      sum += struc["curly"]
    end

    sum
  end


  #
  # Takes single paramter, a string, and returns 
  # the a struct with the elements
  # "ctLeftAngleBrackets", "ctRightAngleBrackets",
  # "ctAmpersands", "ctApostrophes", "ctQuotes",
  # which counts the occurences of the characters
  # "<", ">", "&", "'", '"' 
  #
  def countTheEntities(str)
    { 
      :ctLeftAngleBrackets  => str.count("<"),
      :ctRightAngleBrackets => str.count(">"),
      :ctAmpersands         => str.count("&"),
      :ctApostrophes        => str.count("'"),
      :ctQuotes             => str.count('"')
    }
  end


  # 
  # Takes single parameter, a struct, must return 
  # sum of the three elements "moe", "larry" and "curly"
  #
  def easyStructTest(struc)
    struc["moe"] + struc["larry"] + struc["curly"]
  end


  #
  # Takes single paramter, a struct, must return this
  # struct.
  #
  def echoStructTest(struc)
    struc
  end


  #
  # Takes six parameters and must return an array of this parameters
  #
  def manyTypesTest(number, boolean, string, double, dateTime, base64)
    [number, boolean, string, double, dateTime, base64] 
  end

  
  #
  # Takes single parameter, an array of strings, must return 
  # concatenated string of first and last element of the array.
  #
  def moderateSizeArrayCheck(arr)
    arr[0] + arr[-1]  
  end


  #
  # Takes single parameter, a nested struct that models a calendar.
  # The entry for April 1, 2000 contains three elements "moe", "larry"
  # and "curly". Return the sum of these three elements.
  #
  def nestedStructTest(struc)
    s = struc["2000"]["04"]["01"]
    s["moe"] + s["larry"] + s["curly"]
  end


  # 
  # Takes single parameter, a number and returns a struct
  # containing three elements "times10", "times100" and
  # "times1000" where the values are the multiplication by
  # 10, 100, or 1000.
  #
  def simpleStructReturnTest(n)
    {
      :times10   => n * 10,
      :times100  => n * 100,
      :times1000 => n * 1000
    } 
  end

end




if __FILE__ == $0

  require "xmlrpc/server"

  s = XMLRPC::Server.new(8080, "0.0.0.0")
  s.add_handler("validator1", Validator1.new)
  s.serve

end


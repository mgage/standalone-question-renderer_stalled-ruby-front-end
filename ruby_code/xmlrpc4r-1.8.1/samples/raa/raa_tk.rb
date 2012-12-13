#!/usr/bin/env ruby

#
# Tk client for XML-RPC RAA Interface
# 
# Copyright (C) 2001 by Michael Neumann (mneumann@ntecs.de)
#

require "tk"
require "tkscrollbox"
require "raa"


HOST = ARGV.shift || "www.ruby-lang.org"
PATH = ARGV.shift || "/~nahi/xmlrpc/raa/"
PORT = (ARGV.shift || 80).to_i

INDENT = "    "



raa = RAA.new(HOST, PATH, PORT)


root  = TkRoot.new { title "TkRAA (XML-RPC)"; width "600"}
lframe = TkFrame.new(root)
rframe = TkFrame.new(root)

def generate_listing(raa)
  l = []
  t = raa.getProductTree
  t.keys.sort.each {|i|
   l << { :text => i, :type => :maj } 
    t[i].keys.sort.each {|j|
      l << { :text => j, :type => :min }
      t[i][j].sort.each {|k|
        l << { :text => k, :type => :entry }
      }
    }
  }

  return l
end

$list = generate_listing(raa)




list = TkScrollbox.new(lframe) {
  relief 'raised'
  setgrid 'yes'
  pack 'side' => 'left', 'fill' => 'both', 'expand' => 'yes'
}

$list.each {|i|
  txt = i[:text]

  list.insert('end',
    case i[:type]
    when :maj   then txt
    when :min   then INDENT + txt
    when :entry then (INDENT*2) + txt
    end
  )

}


list.bind("ButtonRelease-1") {
  index = list.curselection[0].to_i
  entry = $list[index]

  if entry[:type] == :entry then
    info = raa.getInfoFromName(entry[:text])
    $product.keys.each {|k| 
      $product[k].value = info["product"][k.to_s]  
    } 

    $owner.keys.each {|k| 
      $owner[k].value = info["owner"][k.to_s]  
    } 

    $category.keys.each {|k| 
      $category[k].value = info["category"][k.to_s]  
    } 

    $update.value = info["update"].to_time.to_s
  end
}


$product = {}
$product[:download]    = TkVariable.new
$product[:status]      = TkVariable.new
$product[:version]     = TkVariable.new
$product[:license]     = TkVariable.new
$product[:name]        = TkVariable.new
$product[:homepage]    = TkVariable.new
$product[:description] = TkVariable.new

$owner = {}
$owner[:email] = TkVariable.new
$owner[:name]  = TkVariable.new
$owner[:id]    = TkVariable.new

$category = {}
$category[:major] = TkVariable.new
$category[:minor] = TkVariable.new

$update = TkVariable.new




def label_entry(parent, label, tkvar, row, klass_entry=TkEntry)
  TkLabel.new(parent) {
    text label
  }.grid('row' => row, 'column' => 0, 'sticky' => 'w')
  
  klass_entry.new(parent) {
    textvariable tkvar
    width 50
  }.grid('row' => row, 'column' => 1)
end

def label(parent, label, row)
  TkLabel.new(parent) {
    text label
  }.grid('row' => row, 'column' => 1, 'sticky' => 'w')
end
  

rtframe = TkFrame.new(rframe)
rbframe = TkFrame.new(rframe)


TkButton.new(rtframe) {
  text "Exit"
  command { exit }
  pack 'side' => 'left'
}


prod = rbframe
label prod, "Product",0
label_entry(prod, "Name", $product[:name], 5)
label_entry(prod, "Version", $product[:version], 3)
label_entry(prod, "Status", $product[:status], 2)
label_entry(prod, "License", $product[:license], 4)
label_entry(prod, "Homepage", $product[:homepage], 6)
label_entry(prod, "Download", $product[:download], 1)
label_entry(prod, "Description", $product[:description], 7)


owner = rbframe
label owner, "Owner",8
label_entry(owner, "Name", $owner[:name], 10)
label_entry(owner, "Email", $owner[:email], 9)
label_entry(owner, "Id", $owner[:id], 11)

categ = rbframe
label categ, "Category",12
label_entry(categ, "Major", $category[:major], 13)
label_entry(categ, "Minor", $category[:minor], 14)

label rbframe, "Update",15
label_entry(rbframe, "Update", $update, 16)
label rbframe, "", 17


rtframe.pack 'side' => 'top', 'fill' => 'both'
rbframe.pack 'side' => 'bottom', 'fill' => 'both'


lframe.pack 'side' => 'left', 'fill' => 'both', 'expand' => 'yes'
rframe.pack 'side' => 'right', 'fill' => 'both', 'expand' => 'yes'


Tk.mainloop




  

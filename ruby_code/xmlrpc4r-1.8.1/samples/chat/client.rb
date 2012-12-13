#!/usr/bin/env ruby

#
# The chat client
# 
# Copyright (C) 2001 by Michael Neumann (mneumann@ntecs.de)
#

require "xmlrpc/client"
require "xmlrpc/server"
require "gtk"

CLIENT_HOST = "localhost" 
CLIENT_PORT = (ARGV[0] || 7001).to_i
SERVER_HOST = "localhost"
SERVER_PORT = "7000"
CHANNEL = "mychannel"

s = XMLRPC::Server.new(CLIENT_PORT)
s.add_handler("chat.client.message") do |channel, message|
#  $msg.configure('text'=>$msg.cget('text') + message)

  true
end


chat_server = XMLRPC::Client.new(SERVER_HOST, "/RPC2", SERVER_PORT)
chat_server.call("chat.server.connect", CHANNEL, CLIENT_HOST, CLIENT_PORT)


server_thread = Thread.new(s) do |server|
  server.serve
end






window = Gtk::Window.new(Gtk::WINDOW_TOPLEVEL)
window.signal_connect("delete_event") do exit end
window.signal_connect("destroy_event") do exit end
window.realize

box = Gtk::VBox.new(FALSE, 0)
window.add(box)
box.show

$str = "Hello, world."
$text = Gtk::Text.new(Gtk::Adjustment.new(0,0,0,0,0,0),
		      Gtk::Adjustment.new(0,0,0,0,0,0))
box.pack_start($text)
$text.show

button = Gtk::Button.new("append")
box.pack_start(button)
button.show
button.signal_connect("clicked") do |w|
  #chat_server.call("chat.server.send", CHANNEL, $entry.value+"\n")
  $text.insert_text($str + "\n", $text.get_point)
end

window.show

Gtk.main

 

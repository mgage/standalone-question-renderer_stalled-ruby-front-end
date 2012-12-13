=begin
= xmlrpc4r - XML-RPC for Ruby
Copyright (C) 2001, 2002, 2003 by Michael Neumann (mneumann@ntecs.de)

Released under the same term of license as Ruby.

== What is XML-RPC ?
XML-RPC provides remote procedure calls over HTTP with XML. It is like SOAP but
much easier. For more information see the XML-RPC homepage 
((<URL:http://www.xmlrpc.com/>)).

== HOWTO
See ((<here|URL:howto.html>)).

== Documentation
* ((<Base64|URL:base64.html>)) 
* ((<DateTime|URL:datetime.html>)) 
* ((<Client|URL:client.html>)) 
* ((<Server|URL:server.html>)) 

== Features

: Extensions
* Introspection
* multiCall
* optionally nil values and integers larger than 32 Bit

: Server
* Standalone XML-RPC server
* CGI-based (works with FastCGI)
* Apache mod_ruby server
* WEBrick servlet

: Client
* synchronous/asynchronous calls
* Basic HTTP-401 Authentification
* HTTPS protocol (SSL)

: Parser
* NQXMLStreamParser
* NQXMLTreeParser
* XMLStreamParser (fastest)
* XMLTreeParser
* REXMLStreamParser
* XMLScanStreamParser
 
: General
* possible to choose between XMLParser Module (Expat wrapper) and NQXML (pure Ruby) parsers
* Marshalling Ruby objects to Hashs and reconstruct them later from a Hash
* SandStorm component architecture Client interface


== ChangeLog
See ((<here|URL:ChangeLog.html>)).

== Download
xmlrpc4r can be downloaded from ((<here|URL:http://www.ntecs.de/downloads/xmlrpc4r/>)).

== Further information
For more information on installation and prerequisites read the (('README')) 
file of the package.

=end

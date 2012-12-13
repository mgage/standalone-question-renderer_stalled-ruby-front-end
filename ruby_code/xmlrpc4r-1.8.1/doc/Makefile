RD=rd2 -r rd/rd2html-lib --with-css=rubyStyle.css

doc:
	${RD} --html-title="xmlrpc4r - XML-RPC for Ruby" index.rd  > index.html
	${RD} --html-title="xmlrpc4r - HOWTO" howto.rd             > howto.html
	${RD} --html-title="xmlrpc/base64.rb" ../lib/base64.rb     > base64.html
	${RD} --html-title="xmlrpc/client.rb" ../lib/client.rb     > client.html
	${RD} --html-title="xmlrpc/server.rb" ../lib/server.rb     > server.html
	${RD} --html-title="xmlrpc/datetime.rb" ../lib/datetime.rb > datetime.html
	${RD} --html-title="ChangeLog for xmlrpc4r" ../ChangeLog   > ChangeLog.html

clean:
	rm *.html

require "xmlrpc/server"

module XMLRPC
class WWWServer < WWWsrv::Document

  def initialize(server)
    @server = server
  end

  def session(sid, srv_opt, prefix, request, response)
    srv_opt.log.debug "sid #{sid}: debug #{type}"

    case (request.method)
    when 'POST'
      if request.header.content_type != "text/xml"
        response.status = 400
        http_error(response)
      end

      length = request.header.content_length.to_i

      if length <= 0
        response.status = 411
        http_error(response)
      end

      #request.content.binmode
      data = request.content.read(length)

      if data.nil? or data.size != length
        response.status = 400
        http_error(response)
      end

      resp = @server.process(data)
      
      response.status = 200
      response.header.content_type = 'text/xml'
      yield(response)
      yield(resp)
    else
      response.status = 405
      http_error(response)
    end

  end
end # class WWWServer
end # module XMLRPC


#
# Client-interface wrapper for Sand-Storm component architecture
# (sstorm.sourceforge.net)
#

require "xmlrpc/client"

module Active

  
  class Registry

    attr_reader :registry

    def initialize(uri=nil, host=nil, port=nil)
      @server   = host || ENV['ACTIVE_REGISTRY_HOST'] || 'localhost'
      @port     = port || ENV['ACTIVE_REGISTRY_PORT'] || 1422
      @uri      = uri  || ENV['ACTIVE_REGISTRY_URI']  || '/RPC2' 

      @active   = XMLRPC::Client.new(@server, @uri, @port.to_i)
      @registry = @active.proxy("active.registry")
    end

    def getComponent(comp)
      info = @registry.getComponent(comp)
      XMLRPC::Client.new(info['host'], info['uri'], info['port']).proxy(comp)
    end

    def getComponents
      @registry.getComponents
    end

    def getComponentInfo(comp)
      @registry.getComponent(comp)
    end

    def setComponent(name, uri, host, port)
      @registry.setComponent(name, uri, host, port)
    end

    def addComponent(name, uri, host, port)
      @registry.addComponent(name, uri, host, port)
    end

    def removeComponent(name)
      @registry.removeComponent(name)
    end

  end # class Registry

  Client = Registry

end # module Active


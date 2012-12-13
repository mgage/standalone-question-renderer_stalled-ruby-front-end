#
# Copyright (C) 2002 by Michael Neumann (mneumann@ntecs.de)
#

def require(file)
  if file =~ /^xmlrpc\/(.*)$/
    file = "../lib/#$1"
    super(file)
  else
    super
  end 
end

def check(file, klass)
  begin
    require file
    klass
  rescue LoadError
    nil
  end
end

def check_installed_parsers
  installed = []
  installed << check('nqxml/treeparser', 'NQXMLTreeParser')
  installed << check('nqxml/streamingparser', 'NQXMLStreamParser')

  installed << check('xmltreebuilder', 'XMLTreeParser')
  installed << check('xmlparser', 'XMLStreamParser')

  installed << check('rexml/document', 'REXMLStreamParser')

  installed << check('xmlscan/parser', 'XMLScanStreamParser')

  installed.delete(nil)
  return installed
end


p check_installed_parsers

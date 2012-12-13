# Enumeration
def enum(start, count)
  (start...(start+count)).to_a
end

module Responder
  # Initialize the array of associations for the class as empty
  @@assocs = []

  # Look up array index of this message map entry
  def assocIndex(lo, hi)
    currIndex = -1
    @@assocs.each_index { |i|
      if @@assocs[i][0] == lo && @@assocs[i][1] == hi
        currIndex = i
      end
    }
    return currIndex
  end

  # Add new or replace existing map entry
  def addMapEntry(lo, hi, func)
    currIndex = assocIndex(lo, hi)
    if currIndex < 0
      @@assocs.push([lo, hi, func])
    else
      @@assocs[currIndex] = [lo, hi, func]
    end
  end

  # Define range of function types
  def FXMAPTYPES(typelo, typehi, func)
    addMapEntry(MKUINT(MINKEY, typelo), MKUINT(MAXKEY, typehi), func)
  end

  # Define one function type
  def FXMAPTYPE(type, func)
    addMapEntry(MKUINT(MINKEY, type), MKUINT(MAXKEY, type), func)
  end

  # Define range of functions
  def FXMAPFUNCS(type, keylo, keyhi, func)
    addMapEntry(MKUINT(keylo, type), MKUINT(keyhi, type), func)
  end

  # Define one function
  def FXMAPFUNC(type, id, func)
    addMapEntry(MKUINT(id, type), MKUINT(id, type), func)
  end
end

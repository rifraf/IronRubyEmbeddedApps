# Bootstrapper patches load and require so that files can be
# read from SERFS (Simple Embedded Resource File System)
# It finishes by loading $0 (which should be set up before entry)

def read_embedded_file(path)
  $LOAD_PATH.each do |loc|
    test = "#{loc}/#{path}".gsub(/\\/,'/')
    str = SerfsInstance.read(test)
    return str.to_s if str
  end
  false
end

# TODO: If the optional wrap parameter is true, the loaded script will be executed under an anonymous module, 
# TODO: protecting the calling program's global namespace.
# TODO: In no circumstance will any local variables in the loaded file be propagated to the loading environment. 
def load_embedded_file(path, wrap = false)
  str = read_embedded_file(path)
  if (str) 
    eval str, nil, path
    return true
  end
  false
end

# Patch 'load'
alias old_load load
def load(filename, wrap = false)
  old_load(filename, wrap)
  rescue LoadError => load_error
    if load_error.message =~ /#{Regexp.escape filename}\z/ and load_embedded_file(filename, wrap)
      return true		
    end
  raise load_error
end

# Patch 'require'
alias old_require require
def require(path)
  return false if $".include?(path)
  old_require(path) 
  rescue LoadError => load_error
    if load_error.message =~ /#{Regexp.escape path}\z/
      str = (read_embedded_file(path + ".rb") || read_embedded_file(path))
	  if str
	    $" << path
	    eval str, nil, path
        return true		
	  end
    end
  raise load_error
end
private :old_require
private :require

# Run
load $0 if $0

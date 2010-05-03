# --------------------------------------------------
# Patch load to try Serfs if disk file is not found
# --------------------------------------------------
def load_embedded_file(path, wrap = false)
  # TODO: If the optional wrap parameter is true, the loaded script will be executed under an anonymous module, 
  # TODO: protecting the calling program's global namespace.
  # TODO: In no circumstance will any local variables in the loaded file be propagated to the loading environment. 
  str = SerfsInstance.read_embedded_file(path)
  if (str) 
    eval(str, nil, '/' + path, 0)
    return true
  end
  false
end

alias old_load load
def load(filename, wrap = false)
  filename.gsub!(/^\//,'')
  old_load(filename, wrap)
  rescue LoadError => load_error
    $! = nil
    if (load_error.message =~ /#{Regexp.escape filename}\z/) and load_embedded_file(filename, wrap)
      return true		
    end
  raise load_error
end
private :old_load
private :load


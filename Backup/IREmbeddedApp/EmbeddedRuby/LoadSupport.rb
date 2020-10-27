# --------------------------------------------------
# Patch load to try Serfs if disk file is not found
# --------------------------------------------------

alias irembedded_old_load load
def load(filename, wrap = false)
  filename.gsub!(/^\//,'')
  irembedded_old_load(filename, wrap)
  rescue LoadError => load_error
    $! = nil
    if (load_error.message =~ /#{Regexp.escape filename}\z/) and load_embedded_string(SerfsInstance.read_embedded_file(filename), filename, wrap)
      return true		
    end
  raise load_error
end
private :irembedded_old_load
private :load


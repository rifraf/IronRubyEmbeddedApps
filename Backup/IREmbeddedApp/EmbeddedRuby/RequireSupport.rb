# This is called with the constant SerfsInstance already referencing 
# an instance of Serfs from which to access embedded resource files.
# It first patches *require* so that it can find files via SerfsInstance.
# It then uses require to pull in support for *load*, *IO* etc.
# Finally it finishes by loading $0 (which should be set up before entry)

#-------------------
# Extend Serfs class
#-------------------
load_assembly SerfsDll

class SERFS::Serfs

  attr_accessor :debug

  def load_path_invalid?(loc) 
    loc =~ /^[a-zA-Z]:/
  end
  
  def get_serf_name(loc, path)
    return path[1..-1] if path =~ /^[\/]/
    return path[2..-1] if path =~ /^\.[\/]/
    "#{loc}/#{path}".gsub(/\\/,'/').gsub(/^\/\//, './')
  end
  
  # Try to read complete file to a string
  def read_embedded_file(path)
    str = nil
    $LOAD_PATH.each do |loc|
      next if load_path_invalid?(loc)
      serf_name = get_serf_name(loc, path)
      str = self.read(serf_name)
      return str.to_s if str
    end
    false
  end

  # Look for a match in the path
  def find_embedded_path(path)
    str = nil
    $LOAD_PATH.each do |loc|
      next if load_path_invalid?(loc)
      serf_name = get_serf_name(loc, path)
      return serf_name if FolderExists(serf_name)
    end
    nil
  end

end

# --------------------------------------------------
# Patch require to try Serfs if disk file is not found
# --------------------------------------------------
alias irembedded_old_require require
def require(path)

  puts("======================= require > #{path}") if SerfsInstance.debug
  
  # Skip if we've seen file already
  filename_non_rb = path.gsub(/\.rb$/i,'')
  return false if $".include?(filename_non_rb)
  
  # Defer to disk
  irembedded_old_require(path) 
  rescue LoadError => load_error
    if load_error.message =~ /#{Regexp.escape path}\z/
      puts("Try #{path}") if SerfsInstance.debug
      filename = filename_non_rb + ".rb"
      str = SerfsInstance.read_embedded_file(filename)
      unless (str) 
        filename = filename_non_rb
        str = SerfsInstance.read_embedded_file(filename)
      end
	  if str
	    $! = nil
	    $" << filename_non_rb
	    $" << path
        puts("Found #{filename}") if SerfsInstance.debug
		begin
	      load_embedded_string(str, filename, false)
	    rescue Exception => e
          puts("Caught (#{filename}):" + e.message) if SerfsInstance.debug
          raise e
	    end
        return true		
	  end
    end
  raise load_error
end
private :irembedded_old_require
private :require

def load_embedded_string(str, path, wrap = false)
  # TODO: If the optional wrap parameter is true, the loaded script will be executed under an anonymous module, 
  # TODO: protecting the calling program's global namespace.
  # TODO: In no circumstance will any local variables in the loaded file be propagated to the loading environment. 
  if (str) 
    eval(str, TOPLEVEL_BINDING, '/' + path, 0)
    return true
  end
  false
end

#SerfsInstance.debug = true
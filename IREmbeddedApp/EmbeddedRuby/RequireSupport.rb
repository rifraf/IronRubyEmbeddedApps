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
	      eval(str, nil, '/' + filename, 0)
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


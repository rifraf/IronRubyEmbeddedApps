# Bootstrapper patches load and require so that files can be
# read from SERFS (Simple Embedded Resource File System)
# It finishes by loading $0 (which should be set up before entry)

# ------------------------------------
# Link to Serfs for file access
# File emulation is limited at the moment
# ------------------------------------
module SerfSupp

  def self.Debug 
    false
  end
  
  #---------------------
  # Autoload support
  #---------------------
  def self.autoloadable
    @autoloadable ||= {}
  end
  
  def self.autoloaded
    @autoloaded ||= {}
  end		

  #---------------------
  # File opening
  #---------------------
  def self.load_path_invalid(loc) 
    loc =~ /^[a-zA-Z]:/
  end
  
  def self.get_serf_name(loc, path)
    return path[1..-1] if path =~ /^[\/]/
	"#{loc}/#{path}".gsub(/\\/,'/').gsub(/^\/\//, './')
  end
  
  # Try to read complete file to a string
  def self.read_embedded_file(path)
    str = nil
    $LOAD_PATH.each do |loc|
      next if load_path_invalid(loc)
      serf_name = get_serf_name(loc, path)
      str = SerfsInstance.read(serf_name)
      return str.to_s if str
    end
    false
  end

  # Try to open file as a stream
  def self.read_embedded_stream(path)
    $LOAD_PATH.each do |loc|
      next if load_path_invalid(loc)
      serf_name = get_serf_name(loc, path)
      stream = SerfsInstance.open_read(serf_name)
      return stream if stream
    end
    false
  end
  
  #---------------------
  # Mock up a class that responds like File::Stat
  # Very limited support at the moment
  #---------------------
  class SerfStat
    attr_reader :mtime, :size
    def initialize(filename, content)
      @mtime = Time.now
      @size = content.size
    end    
  end
  
  # Provide File::stat equivalent
  def self.stat(filename)
	str = read_embedded_file(filename)
    SerfStat.new(filename, str) if str
  end

  #---------------------
  # Provide File::open equivalent
  #---------------------
  def self.open(filename, *args, &blk)
	stream = read_embedded_stream(filename)
	return nil unless stream

	# Sinatra hack
	class << stream
      def each
        rewind
        while buf = read(8192)
          yield buf
        end
      end
	end
	
	stream
  end
    
end

# --------------------------------------------------
# Patch System::IO::UnmanagedMemoryStream to look 
# more like an open file
# --------------------------------------------------
class System::IO::UnmanagedMemoryStream

  def rewind
    self.position = 0	
  end
  
  def read(num)
    buffer = String.CreateBinary(System::IO::BinaryReader.new(self).ReadBytes(num))
	(buffer.length == 0) ? nil : buffer
  end
  
end

# --------------------------------------------------
# Patch load to try Serfs if disk file is not found
# --------------------------------------------------
def load_embedded_file(path, wrap = false)
  # TODO: If the optional wrap parameter is true, the loaded script will be executed under an anonymous module, 
  # TODO: protecting the calling program's global namespace.
  # TODO: In no circumstance will any local variables in the loaded file be propagated to the loading environment. 
  str = SerfSupp.read_embedded_file(path)
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
    if load_error.message =~ /#{Regexp.escape filename}\z/ and load_embedded_file(filename, wrap)
      return true		
    end
  raise load_error
end
private :old_load
private :load

# --------------------------------------------------
# Patch require to try Serfs if disk file is not found
# --------------------------------------------------
alias old_require require
def require(path)

  puts("======================= require > #{path}") if SerfSupp.Debug
  
  # Skip if we've seen file already
  filename_non_rb = path.gsub(/\.rb$/i,'')
  return false if $".include?(filename_non_rb)
  
  # Defer to disk
  old_require(path) 
  rescue LoadError => load_error
    if load_error.message =~ /#{Regexp.escape path}\z/
      puts("Try #{path}") if SerfSupp.Debug
      filename = filename_non_rb + ".rb"
      str = SerfSupp.read_embedded_file(filename)
      unless (str) 
        filename = filename_non_rb
        str = SerfSupp.read_embedded_file(filename)
      end
	  if str
	    $! = nil
	    $" << filename_non_rb
	    $" << path
        puts("Found #{filename}") if SerfSupp.Debug
		begin
	      eval(str, nil, '/' + filename, 0)
	    rescue Exception => e
          puts("Caught (#{filename}):" + e.message) if SerfSupp.Debug
          raise e
	    end
        return true		
	  end
    end
  raise load_error
end
private :old_require
private :require

# -----------------------------------------------------------
# Replace Module#autoload with one that uses the new require
# Thanks http://github.com/defunkt/fakefs
# -----------------------------------------------------------
class Module

  alias old_const_missing const_missing
  def const_missing(name)
    puts "MISSING #{name}" if SerfSupp.Debug
    SerfSupp.autoloaded[self] ||= {}
    file = autoload?(name)
    if file and !SerfSupp.autoloaded[self][name]
      SerfSupp.autoloaded[self][name] = true
      puts "AUTO.......... #{name}" if SerfSupp.Debug
      require file
      return const_get(name) if const_defined?(name)
    end
    old_const_missing(name)
  end
	
  def autoload( name, file_name )
    SerfSupp.autoloadable[self] ||= {}
    SerfSupp.autoloadable[self][name] = file_name
  end
	
  def autoload? const
    hsh = SerfSupp.autoloadable[self]
    return hsh[const] if hsh
  end	
  
end

# -----------------------------------------------------------
# Kernel tweaks
# -----------------------------------------------------------
module Kernel
  # hide bootstrap.rb from the call chain
  alias old_caller caller
  def caller(num = 0)
    callers = old_caller(num)
    callers.reject{|f| f =~ /^bootstrap\.rb:/}
  end
end

# -----------------------------------------------------------
# File tweaks
# -----------------------------------------------------------
class File

  class << self
    alias old_stat stat
    def stat(filename)
      old_stat(filename)
      rescue Errno::ENOENT => error
        file_stat = SerfSupp.stat(filename)
        return file_stat if file_stat
        raise error
    end
    
    alias old_exist? exist?
    def exist?(filename)
	  old_exist?(filename) || !!(filename =~ /^\//)	# TEMP!!!
	end

    alias old_file? file?
    def file?(filename)
	  old_file?(filename) || !!(SerfSupp.read_embedded_file(filename))
	end
    
    alias old_expand_path expand_path
    def expand_path(path, aDirString = nil)
	  return path if path =~ /^\//
	  old_expand_path(path, aDirString)
	end
       
    alias old_open open
    def open(filename, *args, &blk)
      old_open(filename, *args, &blk)
      rescue => error
        stream = SerfSupp.open(filename, *args, &blk)
        return stream if stream
        raise error
    end
  end
end

#------------
# Run
#------------
load $0.dup if $0


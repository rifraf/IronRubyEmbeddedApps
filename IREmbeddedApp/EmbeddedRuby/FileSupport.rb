# ------------------------------------
# Link to Serfs for file access
# File emulation is limited at the moment
# ------------------------------------
class SERFS::Serfs

  #---------------------
  # File opening
  #---------------------

  # Try to open file as a stream
  def read_embedded_stream(path)
    $LOAD_PATH.each do |loc|
      next if load_path_invalid?(loc)
      serf_name = get_serf_name(loc, path)
      stream = self.open_read(serf_name)
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
  def stat(filename)
	str = read_embedded_file(filename)
    SerfStat.new(filename, str) if str
  end

  #---------------------
  # Provide File::open equivalent
  #---------------------
  def open(filename, *args, &blk)

    # Check the requested open mode. It can be a mode string or a mode number
    open_mode = 'r'	# default
    if args.length > 0
      open_mode = args[0] if args[0].kind_of?(String)
      # TODO : mode number
    end
    
    # Cannot write to embedded resources...
    return nil unless open_mode[0,1] == 'r'
    return nil if open_mode.include?('+')
    
	stream = read_embedded_stream(filename)
	return nil unless stream
	
	open_mode.include?('b') ? stream.select_binarymode : stream.select_textmode
	stream
  end

end

class File

  class << self
    alias old_stat stat
    def stat(filename)
      old_stat(filename)
      rescue Errno::ENOENT => error
        file_stat = SerfsInstance.stat(filename)
        return file_stat if file_stat
        raise error
    end
    
    alias old_exist? exist?
    def exist?(filename)
	  old_exist?(filename) || SerfsInstance.exists(filename) || SerfsInstance.folder_exists(filename)
	end

    alias old_file? file?
    def file?(filename)
	  old_file?(filename) || SerfsInstance.exists(filename)
	end
    
    alias old_expand_path expand_path
    def expand_path(path, aDirString = nil)
	  return path if path =~ /^\//
	  old_expand_path(path, aDirString)
	end
       
    # TODO: service blk
    alias old_open open
    def open(filename, *args, &blk)
      old_open(filename, *args, &blk)
      rescue => error
		puts "FILE:OPEN(#{filename}, #{args.join(', ')})"  if SerfsInstance.debug
        stream = SerfsInstance.open(filename, *args, &blk)
        return stream if stream
        raise error
    end
    
    alias old_new new
    def new(filename, *args)
      old_new(filename, *args)
      rescue Errno::ENOENT => error
		puts "FILE:NEW(#{filename}, #{args.join(', ')})"  if SerfsInstance.debug
        stream = SerfsInstance.open(filename, *args)
        return stream if stream
        raise error
    end
    
  end
end

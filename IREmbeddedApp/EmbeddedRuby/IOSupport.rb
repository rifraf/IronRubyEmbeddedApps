# --------------------------------------------------
# Module to provide standard IO methods on a stream
# These are used to extend actual instances when they
# are created, because we need to override methods
# such as read() with the Ruby-style version
# --------------------------------------------------
module EmbeddedIOStream

  def rewind
    if self.can_seek
	  self.position = 0 
	end
  end
  
  def select_text_reader
    @textmode = true
    rewind   
    @reader = System::IO::StreamReader.new(self)
  end

  def select_binary_reader
    @textmode = false
    rewind
    @reader = System::IO::BinaryReader.new(self, System::Text::Encoding.ASCII)
  end
  
  def read(num)
	return nil if eof?
	if @textmode
	  str = ""
	  last_ch = nil
	  until num == 0
	    ch = reader.Read
	    return str if ch < 0
	    if (ch == 13) && (reader.Peek == 10)
		  ch = reader.Read
	    end
        str << ch
        num -= 1
	  end
	  return str
	else
      buffer = String.CreateBinary(reader.ReadBytes(num))
	  (buffer.length == 0) ? nil : buffer
	end
  end
  
  def gets(aSepString = $/)
	# TODO: Reads the next 'line' from the I/O stream; lines are separated by aSepString. 
	# A separator of nil reads the entire contents, and a zero-length separator 
	# reads the input a paragraph at a time (two successive newlines in the input 
	# separate paragraphs). The stream must be opened for reading or an IOerror will 
	# be raised. The line read in will be returned and also assigned to $_. 
	# Returns nil if called at end of file. 
	$_ = ''
	val = read(1)
	return nil unless val
	while val
	  $_ << val
	  return $_ if (val == aSepString)
	  return $_ if (val.length == 0) && $_[-2,2] == "\n\n"
	  val = read(1)
	end
	return $_
  end
  
  def readline(aSepString = $/)
	raise EOFError if eof?
	gets aSepString
  end
  
  def eof?
	eof = @textmode ? @reader.end_of_stream : (@reader.peek_char < 0)
  end
  
  def reader
	unless @reader
	  rewind
	  @reader = System::IO::StreamReader.new(self)
	end
	@reader
  end
  
  private :reader
end

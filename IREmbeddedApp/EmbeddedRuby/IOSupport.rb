# --------------------------------------------------
# Patch System::IO::UnmanagedMemoryStream to look 
# more like an open file
# --------------------------------------------------
class System::IO::UnmanagedMemoryStream

  def rewind
    self.position = 0	
	@reader = @textmode ? System::IO::StreamReader.new(self) : System::IO::BinaryReader.new(self)
  end
  
  def select_textmode
    @textmode = true
    rewind   
  end

  def select_binarymode
    @textmode = false
    rewind
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

# --------------------------------------------------
# Patch System::IO::MemoryStream to look 
# more like an open file
# TODO: remove duplication with above!!!
# --------------------------------------------------
class System::IO::MemoryStream

  def rewind
    self.position = 0	
	@reader = @textmode ? System::IO::StreamReader.new(self) : System::IO::BinaryReader.new(self)
  end
  
  def select_textmode
    @textmode = true
    rewind   
  end

  def select_binarymode
    @textmode = false
    rewind
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


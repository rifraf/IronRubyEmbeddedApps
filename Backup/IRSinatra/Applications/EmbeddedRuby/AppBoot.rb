# Sinatra hack
#
# Sinatra overrides Stream.each to limit blocks to 
# 8192 bytes. If we are reading from Serfs, this won't
# affect our stream because it is not a _real_ stream.
# Hence the following patch
#
class System::IO::UnmanagedMemoryStream
  def each
    rewind
    while buf = read(8192)
      yield buf
    end
  end
end


# Sample code for reading embedded resource files

# SerfSupp.Debug = true

# File.stat support
stat = File.stat("mydoc.xml")
puts "File time: #{stat.mtime}"
puts "File size: #{stat.size}"

# Read a file in text mode
puts "Text mode:"
f = File.new("mydoc.xml")
p f.readline
f.rewind
p f.readline
count = 1
until f.eof?
 count += 1
 f.readline
end
puts "#{count} lines read"

# Read a file in binary mode
puts "Binary mode:"
f = File.new("mydoc.xml", 'rb')
p f.readline
f.rewind
p f.readline
count = 1
until f.eof?
 count += 1
 f.readline
end
puts "#{count} lines read"

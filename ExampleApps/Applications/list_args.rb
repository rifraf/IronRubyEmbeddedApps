puts "$0 is #{$0}"
puts "__FILE__ is #{__FILE__}"
puts "There are #{ARGV.length} command-line arguments (ARGV)"
ARGV.each_with_index do |arg, index|
  puts "#{index}: #{arg}"
end

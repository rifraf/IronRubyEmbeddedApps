# Sample code from http://germane-software.com/software/rexml/docs/tutorial.html

require "rexml/document"
include REXML

# Simple string load/write
string = <<EOF
  <mydoc>
    <someelement attribute="nanoo">Text, text, text</someelement>
  </mydoc>
EOF
doc = Document.new(string)
doc.write $stdout

doc = Document.new File.new("mydoc.xml")
doc.elements.each("inventory/section") { |element| puts element.attributes["name"] }
p __LINE__
# -> health
# -> food
doc.elements.each("*/section/item") { |element| puts element.attributes["upc"] }
# -> 123456789
# -> 445322344
# -> 485672034
# -> 132957764
root = doc.root
puts root.attributes["title"]
# -> OmniCorp Store #45x10^3
puts root.elements["section/item[@stock='44']"].attributes["upc"]
# -> 132957764
puts root.elements["section"].attributes["name"] 
# -> health (returns the first encountered matching element) 
puts root.elements[1].attributes["name"] 
# -> health (returns the FIRST child element) 
root.detect {|node| node.kind_of? Element and node.attributes["name"] == "food" }
p __LINE__

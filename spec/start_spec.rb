require 'open-uri'
require 'nokogiri'
require 'feedzirra'

FHIR_URI = 'http://www.hl7.org/implement/standards/fhir/profiles-resources.xml'

cache_file = "#{File.dirname(__FILE__)}/tmp/cache.xml"

unless File.exists?(cache_file)
  f = open(FHIR_URI)
  File.open(cache_file, 'w') do |cf|
    cf<< f.readlines.join("\n")
  end
end

doc = Nokogiri::XML(open(cache_file).readlines.join(""))
doc.remove_namespaces!


class ActiveXml
  attr :node

  def initialize(node)
    @node = node
  end

end

class Structure < ActiveXml
  def name
    node.xpath('./type').first[:value]
  end

  def elements
    @elements ||= node.xpath('./element').map{|n| Element.new(n) }
  end

  def root_entity
    name
  end
end

node = doc.xpath('//Profile/structure')[20] #.each do |node|
s = Structure.new(node)
root_entity = s.name
fields  = s.elements.map do |el|
  if el.path.length == 2
    puts "t.#{el.definition.type}  #{el.path[1]}" if el.definition.attribute?
  end
end.compact.join("\n")

puts "Nested entitites"

s.elements.each do |el|
  if el.path.length == 2
    puts "* " + el.path[1] + " #{el.definition.type}" if el.definition.entity?
  end
end

puts <<-RUBY
  create_table #{s.root_entity} do |t|
#{fields}
  end
RUBY


datatype = Datatype.find(type)
datatype.attributes [Datatype]

e = Entity.first

e.attributes
[Entiity]

# Entity
#  .attributes [ Attribute<type> ]
#  .embeddedEntities [ Entity ]
#  .associatedEntities [ Entity ]
#  .references [ Entity ]
#
#
#
#
# end
# [
#   { name: '', fields: [], assocs: [{multiple: true/false, fields: [{name: '', multiple: t/f, fields: []}]}, {}]
# ]

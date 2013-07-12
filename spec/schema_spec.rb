require 'spec_helper'

describe Fhir::Meta::Schema do
  let(:schema) do
    Fhir::Meta::Schema
  end

  before(:each) do
    file_name = File.join(File.dirname(__FILE__), '..', 'fhir-base.xsd')
    Fhir::Meta::Schema.load(file_name)
  end

  it 'should detect simple types' do
    schema.find('integer').should be_simple
    schema.find('id').should be_simple
    schema.find('Element').should be_simple

    schema.find('Extension').should be_complex
    schema.find('QuantityCompararator').should be_complex
    schema.find('Address').should be_complex
  end

  it 'should parse attributes' do
    schema.all.each do |datatype|
      puts datatype.name
      if datatype.complex?
        datatype.attributes.each do |attribute|
          attribute[:type].should be_a Fhir::Meta::Datatype if attribute[:type]
          puts "  #{attribute[:name]} <#{attribute[:type_name]}> #{attribute[:min]}..#{attribute[:max]}"
        end
      elsif datatype.simple?
        datatype.attributes.should be_nil
      end
      puts
    end
  end

  it 'should do something' do
    pending
    file_name = File.join(File.dirname(__FILE__), '..', 'fhir-base.xsd')
    document = Nokogiri::XML(File.open(file_name).readlines.join)
    document.remove_namespaces!

    complex_types = document.xpath('//schema/complexType')

    ext_contents = []
    complex_types.each do |type|
      puts type[:name]

      type.xpath('./attribute').each do |attribute|
        puts "  A #{attribute[:name]} <#{attribute[:type]}>"
      end

      type.xpath('./choice').each do |choice|
        puts "  CH #{choice[:minOccurs]}..#{choice[:maxOccurs]}"
        choice.xpath('./element').each do |element|
          puts "    E #{element[:ref]}"
        end
      end

      type.xpath('./sequence/choice').each do |choice|
        puts "  S CH #{choice[:minOccurs]}..#{choice[:maxOccurs]}"
        choice.xpath('./element').each do |element|
          puts "    E #{element[:name]} <#{element[:type]}>"
        end
      end

      type.xpath('./sequence/element').each do |element|
        puts "  S E #{element[:name]} <#{element[:type]}>"
      end

      type.xpath('./resctirction/enumaeration').each do |enumeration|
        puts "  R EN #{enumeration[:value]}"
      end

      type.xpath('./complexContent/extension/attribute').each do |attribute|
        puts "  CO EXT A #{attribute[:name]} <#{attribute[:type]}>"
      end

      type.xpath('./complexContent/extension/sequence/element').each do |element|
        puts "  CO EXT S E #{element[:name]} <#{element[:type]}>"
      end

      type.xpath('./complexContent/restriction/sequence/element').each do |element|
        puts "  CO R S E #{element[:name]} <#{element[:type]}>"
      end
      puts
    end

  end
end

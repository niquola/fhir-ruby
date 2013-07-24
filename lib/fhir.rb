$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__))
require 'ostruct'
require 'active_support/core_ext'

module Fhir
  autoload :Cli, 'fhir/cli'
  autoload :Resource, 'fhir/resource'
  autoload :ActiveXml, 'fhir/active_xml'
  autoload :Datatype, 'fhir/datatype'
  autoload :ElementsBuilder, 'fhir/elements_builder'
  autoload :Path, 'fhir/path'
  autoload :SimpleMonad, 'fhir/simple_monad'
  autoload :Element, 'fhir/element'
  autoload :Graph, 'fhir/graph'
  autoload :Selection, 'fhir/selection'
  autoload :Node, 'fhir/node'
  autoload :TemplateFunctions, 'fhir/template_functions'
  autoload :SelecionFunctions, 'fhir/selection_functions'
  autoload :NodeFunctions, 'fhir/node_functions'

  def self.configure(&block)
    @config = OpenStruct.new
    block.call(@config)
  end

  def self.graph
    modules = @config.selection_modules
    node_modules = @config.node_modules

    @graph ||= Graph.new(modules: modules, node_modules: node_modules).tap do |g|
      Fhir::Resource.load(@config.fhir_xml)
      Fhir::Datatype.load(@config.datatypes_xsd)
      Resource.all.each do |r|
        r.elements.each do |el|
          expand_datatypes g, g.add(el.path,
                                    comment: el.definition.short,
                                    max: el.definition.max,
                                    min: el.definition.min,
                                    from: :fhir,
                                    type: el.definition.type)
        end
      end
    end
  end

  def self.expand_datatypes(graph, nodes)
    Array(nodes).each do |node|
      next if node.type =~ /Resource\(/
      next if node.type == 'Resource'
      next if node.path.length == 1

      type = Datatype.find(node.type)

      next unless type
      next if %w[Extension Narrative].include?(type.name)

      attrs = ((type && type.complex? && type.attributes) || [])
      attrs.each do |attr|
        return []  unless node.path.size > 1
        node = graph.add(node.path.join(attr.name),
                         type: attr.type_name,
                         max: attr.max == 'unbounded' ? '*' : attr.max,
                         min: attr.min,
                         simple: attr.type.try(:simple?),
                         comment: attr.type.try(:simple?),
                         from: :datatypes,
                         datatype_attr: true)
        expand_datatypes(graph, node)
      end
    end
  end

  def self.generate(&block)
    block.call(graph)
  end
end

module Fhir
  class Node
    attr :graph
    attr :path
    attr :attributes

    def initialize(graph, path, attrs)
      @graph, @path, @attributes = graph, Fhir::Path.new(path), attrs
    end

    def name
      path.last
    end

    def max
      attributes[:max] || '1'
    end

    def min
      attributes[:min] || '0'
    end

    def type
      attributes[:type] || ''
    end

    def comment
      attributes[:comment] || ''
    end

    def inspect
      "<Node:#{@path.inspect}(#{attributes.inspect})>"
    end

    def respond_to_missing?(meth, *args)
      mod.respond_to?(meth)
    end

    def method_missing(name, *args, &block)
      if mod.respond_to?(name)
	mod.send(name, self, graph.selection, *args, &block)
      else
	super
      end
    end

    private

    def mod
      @mod ||= Module.new.tap do |mod|
	mod.send(:extend, NodeFunctions)
	@graph.node_modules.each {|m| mod.send(:extend, m) }
      end
    end
  end
end

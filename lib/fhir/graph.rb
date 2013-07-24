module Fhir
  class Graph
    attr :modules
    attr :node_modules

    def initialize(options = {})
      @index = {}
      @options = options
      @modules = Array(options[:modules])
      @node_modules = Array(options[:node_modules])
    end

    def nodes
      @nodes ||= []
    end

    def add(path, attrs = {})
      raise "Duplicate node #{path} in graph" if @index.key?(path.to_s)
      @index[path.to_s] = true
      node = Node.new(self, path, attrs)
      nodes<< node
      node
    end

    def rule(path_expression, attrs = {})
      nodes.each do |node|
        if node.path == Fhir::Path.new(path_expression)
          node.attributes.merge!(attrs)
        end
      end
    end

    def selection
      Selection.new(self, nodes)
    end
  end
end

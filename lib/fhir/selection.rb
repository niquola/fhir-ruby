module Fhir
  class Selection
    attr :graph

    def initialize(graph, selection)
      @graph = graph
      @selection = selection
    end

    def +(other)
      if other.graph != graph
        raise "Could not sum selections with different graphs"
      end
      if other.respond_to?(:to_a)
        selection(to_a + other.to_a)
      else
        raise 'Could not add selections'
      end
    end

    def flatten
      selection(@selection.to_a.flatten)
    end

    def map(&block)
      selection(@selection.map do |node|
        res = block.call(node)
        if res.is_a?(Fhir::Selection)
          res.to_a
        else
          res
        end
      end)
    end

    def method_missing(name, *args, &block)
      if mod.respond_to?(name)
        mod.send(name, self, *args, &block)
      elsif @selection.respond_to?(name)
        selection(@selection.send(name, *args, &block))
      else
        super
      end
    end

    def to_a
      @selection.to_a
    end

    def respond_to_missing?(method, include_private = false)
      mod.respond_to?(method) || @selection.respond_to?(method)
    end

    def inspect
      "<Selection: #{@selection}>"
    end

    def selection(sel)
      Selection.new(@graph, sel)
    end

    private

    def mod
      @mod ||= Module.new.tap do |mod|
        mod.send(:extend, SelecionFunctions)
        mod.send(:extend, TemplateFunctions)
        @graph.modules.each {|m| mod.send(:extend, m) }
      end
    end
  end
end

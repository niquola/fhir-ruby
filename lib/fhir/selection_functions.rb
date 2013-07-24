module Fhir
  module SelecionFunctions
    def debug(selection, title = nil, attr = nil)
      puts
      puts "DEBUG: #{title}" if title
        puts '-'*20
      puts "\n  " + selection.to_a.map(&(attr || :inspect)).join("\n  ")
      selection
    end

    def select(selection, &block)
      selection.selection(selection.to_a.select(&block))
    end

    def branch(selection, path, &block)
      selection.select do |node|
        node.path <= Fhir::Path.new(path)
      end
    end

    def children(selection)
      selection.map(&:children).flatten
    end

    def simple(selection)
      selection.select do |node|
        node.children.to_a.empty? && node.max == '1'
      end
    end

    def parents(selection)
      selection.map(&:parent)
    end

    def node(selection, path)
      selection.to_a.find do |node|
        node.path == Fhir::Path.new(path)
      end
    end
  end
end

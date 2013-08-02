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

    def branches(selection, *paths, &block)
      paths.map do |path|
	selection.branch(path)
      end.sum
    end

    def children(selection)
      selection.map(&:children).flatten
    end

    def simple(selection)
      selection.select do |node|
        node.children.to_a.empty? && node.max == '1'
      end
    end

    def complex(selection)
      selection.select do |node|
        not node.children.to_a.empty?
      end
    end

    def by_attr(selection, name, val)
      selection.select do |node|
        if node.respond_to?(name)
          node.send(name) == val
        else
          node.attributes[name] == val
        end
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

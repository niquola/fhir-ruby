module Fhir
  module NodeFunctions
    def children(node, selection)
      selection.select do |n|
        node.path.child?(n)
      end
    end

    def parent(node, selection)
      selection.to_a.find do |n|
        n.path.child?(node)
      end
    end

    def ancestors(node, selection)
      selection.select do |n|
        n.path > node.path
      end
    end

    def descendants(node, selection)
      selection.select do |n|
        n.path < node.path
      end
    end
  end
end

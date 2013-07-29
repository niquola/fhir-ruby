class ExpandGraph
  def initialize(graph)
    @graph = graph
  end

  def expand
    @graph.selection.by_attr(:embed, true).each do |node|
      res = node.referenced_resource
      res.descendants.each do |dsc|
        path = node.path.to_a + dsc.path.to_a[1..-1]
        @graph.add(path, dsc.attributes) unless @graph.path_exists?(path)
      end
    end
  end
end

module Fhir
  class ActiveXml
    attr :node
    def initialize(node)
      @node = node
    end

    def self.value_attr(path, name = nil)
      name ||= path.split('/').last
      self.send :define_method, name do
        value_from_path(path)
      end
    end

    def value_from_path(path)
      (node.xpath("./#{path}").first || {})[:value]
    end
  end
end

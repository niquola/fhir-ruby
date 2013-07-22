require 'active_support'
require 'active_support/inflector'
require 'active_support/core_ext/object'
require 'erb'

module Fhir
  module ElementsBuilder
    include TableDefinitions
    include Dsl

    def to_path(path)
      case path
      when ::Fhir::Path
        path
      when ::Fhir::Element
        path.path
      else
        ::Fhir::Path.new(path)
      end
    end

    def monadic(list=[])
      SimpleMonad.new(list, [::Fhir::ElementsBuilder])
    end

    def element(path_array, attrs = {})
      Element.new(to_path(path_array), attrs)
    end

    def find_by_path(list, path)
      list.select { |el| el.path == to_path(path) }
    end

    def sort(elements, &block)
      elements.sort_by(&block)
    end

    def each(elements, &block)
      elements.each(&block)
    end

    #GENERIC MONADS
    def select(elements, &block)
      elements.select(&block)
    end

    def reject(elements, &block)
      elements.reject(&block)
    end

    select :resources do |el|
      el.respond_to?(:type) && el.type == 'Resource'
    end

    select :attributes do |el, path|
      to_path(path).child?(el.path) && !is_resource_ref?(el)
    end

    select :descendants do |el, path|
      el.path < to_path(path)
    end

    select :branch do |el, path|
      el.path <= to_path(path)
    end

    select :children do |el, path|
      to_path(path).child?(el.path)
    end

    select :simple do |el|
      el.attributes[:simple]
    end

    select :singular do |element|
      element.path.size > 1 && element.max == '1'
    end

    select :plural do |element|
      element.path.size > 1 && element.max == '*'
    end

    select :references do |element|
      element.respond_to?(:type) && element.type =~ /^Resource/
    end

    select :complex do |element|
      !element.attributes[:simple] && element.respond_to?(:type) && element.type.present?
    end

    reject :technical_elements do |el|
      %w[extension text contained comparator].include?(el.path.last)
    end

    reject :non_root do |element|
      element.path.size > 1
    end


    def resource_elements(list = [])
      Resource.all.map do |resource|
        resource.elements.map do |el|
          element(el.path,
                  comment: el.definition.short,
                  max: el.definition.max,
                  min: el.definition.min,
                  type: el.definition.type)
        end
      end.flatten
    end

    def expand_with_datatypes(elements)
      elements + elements.map do |el|
        if el.path.size > 1
          expand_with_datatypes(
            element_from_datatype_attrs(
              el, complex_type_attributes(el)
            )
          )
        else
          []
        end
      end.flatten
    end

    def set_simple_attribute(elements)
      elements.map do |el|
        type = Datatype.find(el.type)
        el.clone.tap do |elem|
          elem.attributes[:simple] = (type && type.simple?)
        end
      end
    end

    def complex_type_attributes(el)
      return [] if is_resource_ref?(el)
      type = Datatype.find(el.type)
      (type && type.complex? && type.attributes) || []
    end

    def element_from_datatype_attrs(parent_el, attrs)
      attrs.map do |attr|
        element(parent_el.path.join(attr.name),
                type: attr.type_name,
                max: attr.max == 'unbounded' ? '*' : attr.max,
                min: attr.min,
                simple: attr.type.try(:simple?),
                comment: attr.type.try(:simple?),
                datatype_attr: true)
      end
    end

    def is_resource_ref?(el)
      el.respond_to?(:type) && el.type =~ /^Resource\(/
    end

    def template(elements, path = nil, &block)
      template_str = path ? File.read(path) : block.call
      template = ERB.new(template_str, nil, '%<>-')
      template.filename = path if path
      # elements.each do |el|
      #   el.attributes[:code] = template.result(binding)
      # end
      elements.map do |el|
        template.result(binding)
      end
    end

    def render(elements, indent = 1)
      spaces = '  '*indent
      elements
      .map { |e| e.code.gsub(/^(.+)$/, "#{spaces}\\1") }
      .join("\n")
    end

    def file(elements, folder_path, &block)
      FileUtils.mkdir_p(folder_path)
      elements.each do |el|
        content = el.code
        file_name = block.call(el)
        File.open(File.join(folder_path, file_name), 'w') { |f| f<< content }
      end
    end


    def print(elements, &block)
      elements.each do |el|
        if block_given?
          puts block.call(el)
        else
          p el
          puts
        end
      end
      elements
    end

    def modelize(elements)
      elements.map do |el|
        children = select_children(elements, el.path)
        unless children.empty?
          el.clone.tap do |e|
            e.elements = self.monadic(children)
          end
        end
      end.compact
    end

    def tableize(elements)
      elements.map do |el|
        children = tableize(select_alone_descendants(elements, el.path))
        el.clone.tap do |e|
          e.elements = self.monadic(children)
        end
      end
    end

    def select_alone_descendants(elements, path)
      children = select_children(elements, path)
      children.map do |chld|
        if chld.attributes[:max] && chld.max == '*'
          [chld]
        else
          [chld] + select_alone_descendants(elements, chld.path)
        end
      end.flatten.compact
    end

    def apply_rules(elements, rules)
      elements.each_with_object([]) do |element, acc|
        _, overrides = rules.find { |path, _| to_path(path) == element.path }
        acc << (overrides ? element.dup.tap { |el| el.attributes.merge!(overrides) } : element)
      end
    end

    extend self
  end
end

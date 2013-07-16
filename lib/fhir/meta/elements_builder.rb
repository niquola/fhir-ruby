require 'active_support'
require 'active_support/inflector'
require 'active_support/core_ext/object'
require "erb"
module Fhir
  module Meta
    module ElementsBuilder
      def ensure_path(path)
        unless path.is_a?(Path)
          Path.new(path)
        else
          path
        end
      end

      def monadic(list=[])
        SimpleMonad.new(list,[self])
      end

      def element(path_array, attrs = {})
        Element.new(Path.new(path_array), attrs)
      end

      def find_by_path(list, path)
        path = ensure_path(path)
        list.select {|el| el.path == path }
      end

      def filter_descendants(elements, path)
        path = ensure_path(path)
        elements.select do |el|
          el.path <= path
        end
      end

      def filter_children(elements, path)
        path = ensure_path(path)
        elements.select do |el|
          path.child?(el.path)
        end
      end

      def reject_non_root(elements)
        elements.reject { |element| element.path.size > 1 }
      end

      def reject_singular(elements)
        elements.reject do |element|
          element.path.size > 1 && element.max == '1'
        end
      end

      def resource_elements(list = [])
        Resource.all.map do |resource|
          resource.elements.map do |el|
            element(el.path,
                    short: el.definition.short,
                    max: el.definition.max,
                    min: el.definition.min,
                    type: el.definition.type)
          end
        end.flatten
      end

      def expand_with_datatypes(elements)
        elements + elements.map do |el|
          expand_with_datatypes(
            element_from_datatype_attrs(
              el, complex_type_attributes(el)
            )
          )
        end.flatten
      end

      def complex_type_attributes(el)
        return [] if is_resource_ref?(el)
        type = Datatype.find(el.type)
        (type && type.complex? && type.attributes) || []
      end

      def element_from_datatype_attrs(parent_el, attrs)
        attrs.map do |attr|
          element(parent_el.path + [attr.name],
                  type: attr.type_name,
                  max: attr.max == 'unbounded' ? '*' : attr.max,
                  min: attr.min,
                  simple: attr.type.try(:simple?),
                  datatype_attr: true)
        end
      end

      def is_resource_ref?(el)
        el.type =~ /^Resource\(/
      end

      def filter_technical_elements(elements)
        elements.reject do |el|
          %w[extension text contained comparator].include?(el.path.last)
        end
      end

      def template(elements, &block)
        template_str = block.call
        template = ERB.new(template_str, nil, '%<>-')
        elements.map do |el|
          [el, template.result(binding)]
        end
      end

      def file(elements, folder_path, &block)
        FileUtils.mkdir_p(folder_path)
        elements.each do |pair|
          el = pair.first
          content = pair.last
          file_name = block.call(el)
          File.open(File.join(folder_path, file_name), 'w') {|f| f<< content }
        end
      end

      #GENERIC MONADS
      def filter(elements, &block)
        elements.select(&block)
      end

      def filter_simple_types(elements)
        elements.select {|el|
          el.attributes[:simple]
        }
      end

      def sort(elements, &block)
        elements.sort_by(&block)
      end

      def each(elements, &block)
        elements.each(&block)
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
          children = filter_children(elements, el.path)
          unless children.empty?
            el.clone.tap {|e| e.elements = monadic(children) }
          end
        end.compact
      end

      def tableize(elements)
        elements.map do |el|
          children = filter_alone_descendants(elements, el.path)
          unless children.empty?
            el.clone.tap {|e| e.elements = monadic(children) }
          end
        end.compact
      end

      def filter_alone_descendants(elements, path)
        children = filter_children(elements, path)
        children.map do |chld|
          next if chld.attributes[:max] && chld.max == '*'
          [chld] + filter_children(elements, chld.path)
        end.flatten.compact
      end

      def apply_rules(elements, rules)
        elements.each do |element|
          rules.each do |path, rule|
            if element.path == path
              element.attributes.merge!(rule)
            end
          end
        end
      end

      extend self
    end
  end
end

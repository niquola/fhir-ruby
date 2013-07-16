require 'active_support'
require 'active_support/inflector'
require 'active_support/core_ext/object'
require "erb"
module Fhir
  module Meta
    module ElementsBuilder
      class Element
        attr :attributes

        def initialize(attributes)
          @attributes = attributes
        end

        def method_missing(attr)
          if @attributes.key?(attr.to_sym)
            @attributes[attr.to_sym]
          else
            super
          end
        end

        def label
          "#{path.join('.')} (#{type}): #{min}-#{max}"
        end

        def copy
          self.class.new(attributes.dup)
        end

        def class_name
          path.join('_').camelize
        end
      end

      class Monad
        def initialize(list)
          @list = list
        end

        def all
          @list
        end

        def method_missing(method, *args, &block)
          m = Fhir::Meta::ElementsBuilder
          super unless m.respond_to?(method)
          Monad.new(m.send(method, *([@list] + args), &block))
        end
      end

      def monadic(list=[])
        Monad.new(list)
      end

      def element(attrs)
        Element.new(attrs)
      end

      def find_by_path(list, path)
        list.select {|el| el.path == path }
      end

      def filter_descendants(elements, path)
        elements.select do |el|
          el.path.join('.') =~ /^#{path.join('.')}/
        end
      end

      def reject_descendants(elements, path)
        elements.reject do |el|
          el.path.join('.') =~ /^#{path.join('.')}\./
        end
      end

      def filter_children(elements, path)
        elements.select do |el|
          el.path.join('.') =~ /^#{path.join('.')}\.[^.]+$/
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
            element(path: el.path,
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
          element(path: parent_el.path + [attr.name],
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
            el.copy.tap {|e| e.attributes[:elements] = monadic(children) }
          end
        end.compact
      end

      #Entity
      #Entity.one 1
      #Entity.one.prop 1
      #Entity.two 1
      #Entity.two.tree 1
      #Entity.two.tree.prop 1
      # ROOT a -> *b -> 1c
      # ROOT a -> 1d -> 1e
      def tableize(elements)
        elements.map do |el|
          children = filter_alone_descendants(elements, el.path)
          unless children.empty?
            el.copy.tap {|e| e.attributes[:elements] = monadic(children) }
          end
        end.compact
      end

      # ROOT a -> *b -> 1c => [a, b]
      # ROOT a -> 1d -> 1e =  [a, d, e]
      # 1 1 * 11
      # 1 1 1 1
      # 1 1 *
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

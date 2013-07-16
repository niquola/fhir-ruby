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
        elements.select {|el|
          (el.path & ['MedicationStatement']) == ['MedicationStatement']
        }
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
           template.result(binding)
        end
      end

      #GENERIC MONADS
      def filter(elements, &block)
        elements.select(&block)
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
            puts el
          end
        end
        elements
      end

      def modelize(elements)
        models = {}
        index_elements(elements).each do |k, v|
          models[k] = v unless v.empty?
        end
        models
      end

      def index_elements(elements)
        index = {}
        elements.each do |el|
          index[el.path]  = []
          parent_path = el.path[0..-2]
          index[parent_path]<< el if index.key?(parent_path)
        end
        index
      end

      extend self
    end
  end
end

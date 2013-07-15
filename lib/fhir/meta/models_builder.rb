require 'active_support'
require 'active_support/inflector'
module Fhir
  module Meta
    #Collect model from xml
    class ModelsBuilder

      def initialize
      end

      def build
        # Resource.all.map do |resource|
        [Resource.find("MedicationStatement")].map do |resource|
          resource.elements.map do |el|
            next if %[extension text contained].include?(el.path.last)
            if is_model?(el)
              model = Model.new(el.path)
              model.attributes = collect_attributes_from_elements(resource, el)
              model
            elsif is_complex_type?(el.definition.type)
              model =  []
              collect_models_from_complex_type(model, el.path, el.definition.type)
            end
            model
          end
        end.flatten.compact
      end

      def collect_attributes_from_datatype(type)
        Datatype.find(type).
          attributes.select do |attr|
          (attr.type.nil? || attr.type.simple?) && attr.max == '1'
        end.map do |attr|
          Attribute.new(attr.name, attr.type_name)
        end
      end

      def collect_attributes_from_elements(resource, root_el)
        resource.elements.map do |el|
          next unless belongs_to?(root_el.path, el.path)
          next if resource_ref?(el)
          type =  Datatype.find(el.definition.type)

          if type && type.simple?
            Attribute.new(el.path.last.underscore, el.definition.type)
          end
        end.compact
      end

      def collect_models_from_complex_type(acc, path, parent_type)
        acc << Model.new(path).tap do |m|
          m.attributes = collect_attributes_from_datatype(parent_type)
        end

        Datatype.find(parent_type).attributes.each do |attr|
          attr_type = attr.type_name
          next if attr.name =~ /Comparator$/i
          next unless attr.type && attr.type.complex?
          new_path = path.dup + [attr.name]
          collect_models_from_complex_type(acc, new_path, attr_type) if is_complex_type?(attr_type)
        end
      end

      private

      def is_model?(el)
        el.definition.type.nil? || el.definition.type == 'Resource'
      end

      def is_complex_type?(type_name)
        type = Datatype.find(type_name)
        type && type.complex?
      end

      def resource_ref?(el)
        el.definition.type =~ /^Resource\(/
      end

      def belongs_to?(path, p)
        p.join('.') =~ /^#{path.join('\.')}\.[^.]+$/
      end
    end
  end
end

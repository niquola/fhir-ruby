require 'active_support'
require 'active_support/inflector'
module Fhir
  module Meta
    #Collect model from xml
    class ModelsBuilder

      def initialize
      end

      attr :models

      def build
        # @models = [Resource.find("MedicationStatement")].map do |resource|
        @models =  Resource.all.map do |resource|
          resource.elements.map do |el|
            next if is_hiden?(el)
            if is_model?(el)
              model = Model.new(el.path)
              model.attributes = collect_attributes_from_elements(resource, el)
              model.associations.concat collect_associations_from_elements(resource, el)
              model.resource_refs.concat collect_resource_refs_from_elements(resource, el)
              model
            elsif is_complex_type?(el.definition.type)
              model =  []
              collect_models_from_complex_type(model, el.path, el.definition.type)
            end
            model
          end
        end.flatten.compact

        bind_backward_associations

        convert_resources_refs_into_models

        @models
      end

      def find_model(name)
        models.find {|m| m.full_name == name }
      end

      def bind_backward_associations
        models.each do |model|
          model.associations.each do |assoc|
            child_model = find_model assoc.model_name
            if child_model.nil?
              puts "WARN: recursive link #{assoc.model_name}, make desicion!"
            else
              child_model.parent = model
            end
          end
        end
      end

      def collect_attributes_from_elements(resource, root_el)
        resource.elements.map do |el|
          next unless belongs_to?(root_el.path, el.path)
          next if is_resource_ref?(el)
          type =  Datatype.find(el.definition.type)

          if type && type.simple?
            Attribute.new(el.path.last.underscore, el.definition.type)
          end
        end.compact
      end

      def collect_associations_from_elements(resource, root_el)
        resource.elements.map do |el|
          next unless belongs_to?(root_el.path, el.path)
          next if is_resource_ref?(el)
          next if is_hiden?(el)
          type =  Datatype.find(el.definition.type)
          if type.nil? || type.complex?
            Association.new(el.path.last.underscore,
                            el.path.map(&:camelize).join,
                            multiple: el.definition.max == '*', internal: true)
          end
        end.flatten.compact
      end

      def collect_resource_refs_from_elements(resource, root_el)
        resource.elements.map do |el|
          next unless belongs_to?(root_el.path, el.path)
          if is_resource_ref?(el)
            ResourceRef.new(el.name, el.definition.type)
          end
        end.compact
      end

      def collect_attributes_from_datatype(type)
        Datatype.find(type).
          attributes.select do |attr|
          (attr.type.nil? || attr.type.simple?) && attr.max == '1'
        end.map do |attr|
          Attribute.new(attr.name, attr.type_name)
        end
      end


      def collect_models_from_complex_type(acc, path, parent_type)
        model = Model.new(path).tap do |m|
          m.attributes = collect_attributes_from_datatype(parent_type)
        end

        acc << model

        Datatype.find(parent_type).attributes.each do |attr|
          attr_type = attr.type_name
          next if attr.name =~ /Comparator$/i
          next unless attr.type && attr.type.complex?
          new_path = path.dup + [attr.name]
          if is_complex_type?(attr_type)
            collect_models_from_complex_type(acc, new_path, attr_type)
            model.associations<< Association.new(attr.name, new_path.map(&:camelize).join, internal: true)
          end
        end
      end

      def convert_resources_refs_into_models
        embeded_resource_models =  []
        models.each do |model|
          embeded_resource_models.concat convert_resources_refs(model)
        end
        models.concat(embeded_resource_models)
      end

      def convert_resources_refs(model)
        acc = []
        model.resource_refs.map do |ref|
          next if ref.polymorphic?
          res_model = find_model(ref.resources.first)
          next unless res_model
          child_model = Model.new(model.path + [ref.name])
          child_model.attributes = res_model.attributes
          child_model.parent = model
          model.associations << Association.new(ref.name, child_model.full_name, internal: true, multiple: false)
          acc<< child_model
          copy_assocs_recursive(acc, res_model, child_model)
        end
        acc.flatten.compact
      end

      def copy_assocs_recursive(acc, source_model, destination_model)
        source_model.associations.each do |ass|
          child_model = Model.new(destination_model.path + [ass.name])
          source_child_model = find_model(ass.model_name)
          next unless source_child_model
          #FIXME: dup attributes
          child_model.attributes = source_child_model.attributes
          child_model.parent = destination_model
          destination_model.associations << Association.new(ass.name, child_model.full_name, ass.options)
          acc << child_model
          copy_assocs_recursive(acc, source_child_model, child_model)
        end
      end

      private

      def is_hiden?(el)
        %[extension text contained].include?(el.path.last)
      end

      def is_model?(el)
        el.definition.type.nil? || el.definition.type == 'Resource'
      end

      def is_complex_type?(type_name)
        type = Datatype.find(type_name)
        type && type.complex?
      end

      def is_resource_ref?(el)
        el.definition.type =~ /^Resource\(/
      end

      def belongs_to?(path, p)
        p.join('.') =~ /^#{path.join('\.')}\.[^.]+$/
      end
    end
  end
end

# Part of composite
# Allow to use model as part of another object delegating attribute accessors by convention: <composing>__<attr_name>
module Fhir::Composing
  extend ActiveSupport::Concern

  attr_accessor :composite, :composing_name

  def initialize(attrs = {})
    composite = attrs.fetch(:composite)
    composing_name = attrs.fetch(:composing_name)
    if composite.respond_to?(:composing_name)
      self.composite = composite.composite
      self.composing_name = [composite.composing_name, composing_name].join('__')
    else
      self.composite, self.composing_name = composite, composing_name
    end
    self.attributes = attrs.except(:composite, :composing_name)
  end

  def attributes
    composing_attribute_names.each_with_object({}) do |attr_name, attrs|
      attrs[attr_name] = send(attr_name)
    end
  end

  def attributes=(attrs)
    attrs.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def blank?
    attributes.values.all?(&:blank?)
  end

  included do
    class_attribute :composing_attribute_names
    self.composing_attribute_names = []
  end

  private

  def read_composing_attribute(attr_name)
    reader_method_name = "#{composing_name}__#{attr_name}"
    composite.send(reader_method_name) if composite.respond_to?(reader_method_name)
  end

  def write_composing_attribute(attr_name, val)
    composite.send("#{composing_name}__#{attr_name}=", val)
  end

  module ClassMethods
    def composing_attribute(*attribute_names)
      self.composing_attribute_names += attribute_names
      attribute_names.each do |attr_name|
        self.send(:define_method, attr_name) do
          read_composing_attribute(attr_name)
        end

        self.send(:define_method, "#{attr_name}=") do |val|
          write_composing_attribute(attr_name, val)
        end
      end
    end
  end
end
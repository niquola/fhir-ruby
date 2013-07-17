# Composite, allow object to compose group of attributes prefixed with composing name: <composing>__<attr_name>
# Similar to http://apidock.com/rails/ActiveRecord/Aggregations/ClassMethods/composed_of
module Fhir::Composite
  extend ActiveSupport::Concern

  module ClassMethods
    def composing(composing_name, opts = {})
      class_name = opts.fetch(:class_name)
      line = __LINE__
      class_eval <<-RUBY, __FILE__, line + 2
        def build_#{composing_name}(attrs = {})                                       # def build_address(attrs = {})
          @_#{composing_name} = nil                                                   #   @_address = nil
          self.#{composing_name}_attributes = attrs                                   #   self.address_attributes = attrs
          @_#{composing_name}                                                         #   @_address
        end                                                                           # end

        #TODO: entry-point to initialize attribute names by convention
        def _#{composing_name}                                                        # def _address
          @_#{composing_name} ||= begin                                               #   @_address ||= begin
            init_attrs = {composite: self, composing_name: '#{composing_name}'}       #     init_attrs = {composite: self, composing_name: 'address'}
            #{class_name}.new(init_attrs)                                             #     Address.new(init_attrs)
          end                                                                         #   end
        end                                                                           # end

        def #{composing_name}                                                         # def address
          _#{composing_name}.presence                                                 #   _address.presence
        end                                                                           # end

        def #{composing_name}_attributes=(attrs = {})                                 # def address_attributes(attrs = {})
          attrs.each do |name, value|                                                 #   attrs.each do |name, value|
            _#{composing_name}.send("\#{name}=", value)                               #     _address.send("\#{name}=", value)
          end                                                                         #   end
        end                                                                           # end
      RUBY
    end
  end
end
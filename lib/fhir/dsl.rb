require 'active_support'

module Fhir
  module Dsl
    def self.included(mod)
      def mod.select(name, &block)
        define_method "select_#{name}" do |elements, *args|
          elements.select do |el|
            block.call(el, *args)
          end
        end

        define_method "reject_#{name}" do |elements, *args|
          elements.reject do |el|
            block.call(el, *args)
          end
        end
      end

      def mod.reject(name, &block)
        define_method "reject_#{name}" do |elements, *args|
          elements.reject do |el|
            block.call(el, *args)
          end
        end
      end
    end
  end
end

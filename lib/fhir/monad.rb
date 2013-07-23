module Fhir
  class Monad

    class Unpack
      def initialize(val)
	@value = val
      end

      def value
	@value
      end
    end

    module Helpers
      def stop(val)
	Unpack.new(val)
      end
    end

    def initialize(value, modules =[])
      unless modules.empty?
	@mod = Module.new.tap do |worker|
	  worker.extend(Helpers)
	  modules.each do |mod|
	    worker.send(:extend, mod)
	  end
	end
      end
      @value = value
    end

    def unit(value)
      monad = Monad.new(value)
      monad.send('mod=', @mod)
      monad
    end

    def result
      @value
    end

    alias :all :result

    def respond_to?(method)
      @mod.respond_to?(method)
    end

    def method_missing(method, *args, &block)
      super unless @mod.respond_to?(method)
      result = @mod.send(method, *([@value] + args), &block)
      if result.is_a?(Unpack)
	result.value
      else
	unit(result)
      end
    end

    private

    attr :mod

    def mod=(mod)
      @mod = mod
    end
  end
end

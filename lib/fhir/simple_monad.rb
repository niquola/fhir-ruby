module Fhir
  class SimpleMonad
    def initialize(payload, modules =[])
      unless modules.empty?
        @mod = Module.new.tap do |worker|
          modules.each do |mod|
            worker.send(:extend, mod)
          end
        end
      end
      @payload = payload
    end

    def payload(payload)
      monad = SimpleMonad.new(payload)
      monad.send('mod=', @mod)
      monad
    end

    def resolve
      @payload
    end

    alias :all :resolve

    def respond_to?(method)
      @mod.respond_to?(method)
    end

    #TODO: exit from monad
    def method_missing(method, *args, &block)
      super unless @mod.respond_to?(method)
      result = @mod.send(method, *([@payload] + args), &block)
      payload(result)
    end

    private

    attr :mod

    def mod=(mod)
      @mod = mod
    end
  end
end

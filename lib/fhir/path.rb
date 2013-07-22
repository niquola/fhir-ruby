module Fhir
  class Path
    include Comparable

    def initialize(array)
      @array = array.to_a.freeze
    end

    def inspect
      to_a.join('.')
    end

    def to_a
      @array
    end

    def to_s
      to_a.join('.')
    end

    def subpath?(subpath)
      subpath.to_s.start_with?(self.to_s) && subpath.size > self.size
    end

    def child?(subpath)
      subpath.to_s =~ /^#{to_s}\.[^.]+$/
    end

    alias :include? :subpath?

    def self_or_subpath?(subpath)
      subpath.to_s =~ /^#{self.to_s}/
    end

    def [](range_or_index)
      if range_or_index.is_a?(Range)
        self.class.new(to_a[range_or_index])
      else
        to_a[range_or_index]
      end
    end

    def >=(subpath)
      self_or_subpath?(subpath)
    end

    def <=(superpath)
      superpath.self_or_subpath?(self)
    end

    def >(subpath)
      subpath?(subpath)
    end

    def <(superpath)
      superpath.subpath?(self)
    end

    def length
      to_a.length
    end

    def last
      to_a.last
    end

    def first
      to_a.last
    end

    alias :size :length

    def relative(path)
      raise "#{path} not subpath of #{self}" unless path.subpath?(self)
      self.class.new(to_a[path.length..-1])
    end

    def -(path)
      relative(path)
    end

    def concat(other_path)
      self.class.new(to_a + other_path.to_a)
    end

    def join(*args)
      concat(args)
    end

    def +(other_path)
      concat(other_path)
    end

    def ==(other_path)
      to_a == other_path.to_a
    end

    def <=>(other)
      to_a <=> other.to_a
    end

    def initialize_copy(origin)
      @array = origin.to_a
    end

    alias :eql? :==
  end
end

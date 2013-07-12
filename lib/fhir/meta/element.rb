module Fhir
  module Meta
    class Element < Fhir::Meta::ActiveXml
      def path
        node.xpath('./path').first[:value].split('.')
      end

      def definition
        @definition = Definition.new(node.xpath('./definition').first)
      end

      def name
        path.last
      end

      class Definition < Fhir::Meta::ActiveXml
        def max
          node.xpath('./max').first.try(:[],:value)
        end

        def min
          node.xpath('./min').first.try(:[],:value)
        end

        def type
          type = node.xpath('./type/code').first
          if type
            type[:value]
          else
            nil
          end
        end

        def attribute?
          ! type.nil? && type !~ /^Resource\(/
        end

        def model?
          type.nil? || type == 'Resource'
        end

        def reference?
          ! type.nil? && type =~ /^Resource\(/
        end

        def attributes
        end
      end
    end
  end
end

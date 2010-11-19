module SPARQL; module Algebra
  ##
  # A SPARQL operator.
  class Operator
    autoload :IsIRI,   'sparql/algebra/operator/is_iri'
    autoload :IsBlank, 'sparql/algebra/operator/is_blank'

    ##
    # @param [Hash{Symbol => Object}] options
    def initialize(options = {})
      @options = options.dup
    end

    ##
    # A SPARQL unary operator.
    class Unary < Operator
      ##
      # @param  [Object] arg
      # @return [Object]
      def evaluate(arg)
        raise NotImplementedError, "#{self.class}#evaluate"
      end
    end # Unary

    ##
    # A SPARQL binary operator.
    class Binary < Operator
      ##
      # @param  [Object] arg1
      # @param  [Object] arg2
      # @return [Object]
      def evaluate(arg1, arg2)
        raise NotImplementedError, "#{self.class}#evaluate"
      end
    end # Binary

    ##
    # A SPARQL ternary operator.
    class Ternary < Operator
      ##
      # @param  [Object] arg1
      # @param  [Object] arg2
      # @param  [Object] arg3
      # @return [Object]
      def evaluate(arg1, arg2, arg3)
        raise NotImplementedError, "#{self.class}#evaluate"
      end
    end # Ternary
  end # Operator
end; end # SPARQL::Algebra

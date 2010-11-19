module SPARQL; module Algebra
  ##
  # A SPARQL operator.
  class Operator
    autoload :IsBlank,   'sparql/algebra/operator/is_blank'
    autoload :IsIRI,     'sparql/algebra/operator/is_iri'
    autoload :IsLiteral, 'sparql/algebra/operator/is_literal'

    ##
    # @param [Hash{Symbol => Object}] options
    def initialize(options = {})
      @options = options.dup
    end

    ##
    # A SPARQL unary operator.
    #
    # @abstract
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
    #
    # @abstract
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
    #
    # @abstract
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

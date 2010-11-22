module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL numeric `multiply` operator.
    #
    # @see http://www.w3.org/TR/xpath-functions/#func-numeric-multiply
    class Multiply < Operator::Binary
      NAME = [:*, :multiply]

      ##
      # Initializes a new operator instance.
      #
      # @param  [RDF::Literal::Numeric] left
      #   a numeric RDF literal
      # @param  [RDF::Literal::Numeric] right
      #   a numeric RDF literal
      # @param  [Hash{Symbol => Object}] options
      #   any additional options (see {Operator#initialize})
      # @raise  [TypeError] if any operand is invalid
      def initialize(left, right, options = {})
        super(left, right, options)
      end

      ##
      # Returns the arithmetic product of the operands.
      #
      # @param  [RDF::Query::Solution, #[]] bindings
      # @return [RDF::Literal::Numeric]
      # @raise  [TypeError] if either operand is not an `RDF::Literal::Numeric`
      def evaluate(bindings = {})
        left  = operand(0).evaluate(bindings)
        right = operand(1).evaluate(bindings)
        case
          when left.is_a?(RDF::Literal::Numeric) && right.is_a?(RDF::Literal::Numeric)
            left * right
          else raise TypeError, "expected two RDF::Literal::Numeric operands, but got #{left.inspect} and #{right.inspect}"
        end
      end
    end # Multiply
  end # Operator
end; end # SPARQL::Algebra

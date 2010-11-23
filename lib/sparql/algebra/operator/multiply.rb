module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL numeric `multiply` operator.
    #
    # @see http://www.w3.org/TR/xpath-functions/#func-numeric-multiply
    class Multiply < Operator::Binary
      NAME = [:*, :multiply]

      ##
      # Returns the arithmetic product of the operands.
      #
      # @param  [RDF::Literal::Numeric] left
      #   a numeric literal
      # @param  [RDF::Literal::Numeric] right
      #   a numeric literal
      # @return [RDF::Literal::Numeric]
      # @raise  [TypeError] if either operand is not a numeric literal
      def apply(left, right)
        case
          when left.is_a?(RDF::Literal::Numeric) && right.is_a?(RDF::Literal::Numeric)
            left * right
          else raise TypeError, "expected two RDF::Literal::Numeric operands, but got #{left.inspect} and #{right.inspect}"
        end
      end
    end # Multiply
  end # Operator
end; end # SPARQL::Algebra

module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL numeric unary `+` operator.
    #
    # @see http://www.w3.org/TR/xpath-functions/#func-numeric-unary-plus
    class Plus < Operator::Unary
      NAME = [:+, :plus]

      ##
      # Returns the operand incremented by one.
      #
      # @param  [RDF::Query::Solution] solution
      # @return [RDF::Literal::Numeric]
      # @raise  [TypeError] if the operand is not an `RDF::Literal::Numeric`
      def evaluate(solution)
        case term = operand(0, solution)
          when RDF::Literal::Numeric, Numeric
            RDF::Literal(term + 1)
          else raise TypeError, "expected an RDF::Literal::Numeric, but got #{term.inspect}"
        end
      end
    end # Plus
  end # Operator
end; end # SPARQL::Algebra

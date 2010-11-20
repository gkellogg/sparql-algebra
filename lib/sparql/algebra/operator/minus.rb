module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL numeric unary `-` operator.
    #
    # @see http://www.w3.org/TR/xpath-functions/#func-numeric-unary-minus
    class Minus < Operator::Unary
      NAME = :-

      ##
      # Returns the operand decremented by one.
      #
      # @param  [RDF::Query::Solution] solution
      # @return [RDF::Literal::Numeric]
      # @raise  [ArgumentError] if the operand is not an `RDF::Literal::Numeric`
      def evaluate(solution)
        case term = operands.first # TODO: variable lookup
          when Numeric
            RDF::Literal(term - 1)
          when RDF::Literal::Decimal, RDF::Literal::Double # FIXME: RDF::Literal::Numeric
            term - 1
          else raise ArgumentError, "expected an RDF::Literal::Numeric, but got #{term.inspect}"
        end
      end
    end # Minus
  end # Operator
end; end # SPARQL::Algebra
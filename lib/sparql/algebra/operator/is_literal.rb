module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL `isLiteral` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-isLiteral
    class IsLiteral < Operator::Unary
      NAME = :isLiteral

      ##
      # Returns `true` if the operand is an `RDF::Literal`, `false`
      # otherwise.
      #
      # @param  [RDF::Query::Solution] solution
      # @return [RDF::Literal::Boolean] `true` or `false`
      # @raise  [TypeError] if the operand is not an `RDF::Term`
      def evaluate(solution)
        case term = operand(0, solution)
          when RDF::Literal then RDF::Literal(true)
          when RDF::Value   then RDF::Literal(false) # FIXME: RDF::Term
          else raise TypeError, "expected an RDF::Term, but got #{term.inspect}"
        end
      end
    end # IsLiteral
  end # Operator
end; end # SPARQL::Algebra

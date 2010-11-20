module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL `isBlank` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-isBlank
    class IsBlank < Operator::Unary
      NAME = :isBlank

      ##
      # Returns `true` if the operand is an `RDF::Node`, `false` otherwise.
      #
      # @param  [RDF::Query::Solution] solution
      # @return [RDF::Literal::Boolean] `true` or `false`
      # @raise  [TypeError] if the operand is not an `RDF::Term`
      def evaluate(solution)
        case term = operand(0, solution)
          when RDF::Node then RDF::Literal::TRUE
          when RDF::Term then RDF::Literal::FALSE
          else raise TypeError, "expected an RDF::Term, but got #{term.inspect}"
        end
      end
    end # IsBlank
  end # Operator
end; end # SPARQL::Algebra

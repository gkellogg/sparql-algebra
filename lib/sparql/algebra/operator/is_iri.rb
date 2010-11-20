module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL `isIRI`/`isURI` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-isIRI
    class IsIRI < Operator::Unary
      NAME = [:isIRI, :isURI]

      ##
      # Returns `true` if the operand is an `RDF::URI`, `false` otherwise.
      #
      # @param  [RDF::Query::Solution] solution
      # @return [RDF::Literal::Boolean] `true` or `false`
      def evaluate(solution)
        term = operands.first # TODO: variable lookup
        RDF::Literal(term.is_a?(RDF::URI))
      end
    end # IsIRI
  end # Operator
end; end # SPARQL::Algebra

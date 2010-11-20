module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL `isLiteral` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-isLiteral
    class IsLiteral < Operator::Unary
      ##
      # Returns `true` if the argument is an `RDF::Literal`, `false`
      # otherwise.
      #
      # @param  [RDF::Query::Solution] solution
      # @return [RDF::Literal::Boolean] `true` or `false`
      def evaluate(solution)
        term = @arg # TODO: variable lookup
        RDF::Literal(term.is_a?(RDF::Literal))
      end
    end # IsLiteral
  end # Operator
end; end # SPARQL::Algebra
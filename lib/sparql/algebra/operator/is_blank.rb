module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL `isBlank` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-isBlank
    class IsBlank < Operator::Unary
      ##
      # Returns `true` if the argument is an `RDF::Node`, `false` otherwise.
      #
      # @param  [RDF::Query::Solution] solution
      # @return [RDF::Literal::Boolean] `true` or `false`
      def evaluate(solution)
        term = @arg # TODO: variable lookup
        RDF::Literal(term.is_a?(RDF::Node))
      end
    end # IsBlank
  end # Operator
end; end # SPARQL::Algebra
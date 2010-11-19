module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL `isBlank` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-isBlank
    class IsBlank < Operator::Unary
      ##
      # Returns `true` if `term` is an `RDF::Node`, `false` otherwise.
      #
      # @param  [RDF::Value] term an RDF term
      # @return [RDF::Literal::Boolean] `true` or `false`
      def evaluate(term)
        RDF::Literal(term.is_a?(RDF::Node))
      end
    end # IsBlank
  end # Operator
end; end # SPARQL::Algebra

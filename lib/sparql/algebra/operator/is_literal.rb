module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL `isLiteral` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-isLiteral
    class IsLiteral < Operator::Unary
      ##
      # Returns `true` if `term` is an `RDF::Literal`, `false` otherwise.
      #
      # @param  [RDF::Value] term an RDF term
      # @return [RDF::Literal::Boolean] `true` or `false`
      def evaluate(term)
        RDF::Literal(term.is_a?(RDF::Literal))
      end
    end # IsLiteral
  end # Operator
end; end # SPARQL::Algebra

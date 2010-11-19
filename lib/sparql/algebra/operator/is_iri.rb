module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL `IsIRI`/`IsURI` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-isIRI
    class IsIRI < Operator::Unary
      ##
      # Returns `true` if `term` is an `RDF::URI`, `false` otherwise.
      #
      # @param  [RDF::Value] term an RDF term
      # @return [RDF::Literal::Boolean] `true` or `false`
      def evaluate(term)
        RDF::Literal(term.is_a?(RDF::URI))
      end
    end # IsIRI
  end # Operator
end; end # SPARQL::Algebra

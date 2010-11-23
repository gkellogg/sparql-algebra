module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL `sameTerm` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-sameTerm
    class SameTerm < Operator::Binary
      NAME = :sameTerm

      ##
      # Returns `true` if the operands are the same RDF term; returns
      # `false` otherwise.
      #
      # @param  [RDF::Term] term1
      #   an RDF term
      # @param  [RDF::Term] term2
      #   an RDF term
      # @return [RDF::Literal::Boolean] `true` or `false`
      # @raise  [TypeError] if either operand is unbound
      def apply(term1, term2)
        RDF::Literal(term1.eql?(term2))
      end
    end # SameTerm
  end # Operator
end; end # SPARQL::Algebra

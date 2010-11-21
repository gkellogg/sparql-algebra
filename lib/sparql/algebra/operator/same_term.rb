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
      # @param  [RDF::Query::Solution, #[]] bindings
      # @return [RDF::Literal::Boolean]
      # @raise  [TypeError] if either operand is unbound
      def evaluate(bindings = {})
        lhs = operand(0).evaluate(bindings)
        rhs = operand(1).evaluate(bindings)
        RDF::Literal(lhs.eql?(rhs)) # FIXME
      end
    end # SameTerm
  end # Operator
end; end # SPARQL::Algebra

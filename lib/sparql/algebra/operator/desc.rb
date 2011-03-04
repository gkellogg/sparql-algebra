module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL descending sort operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-isLiteral
    class Desc < Operator::Unary
      NAME = :desc

      ##
      # Returns the evaluation of it's operand. Default comparison is in
      # ascending order. Ordering is applied in {Order}.
      #
      # @param  [RDF::Query::Solution, #[]] bindings
      # @return [RDF::Term]
      def evaluate(bindings = {})
        operand(0).evaluate(bindings)
      end
    end # Desc
  end # Operator
end; end # SPARQL::Algebra

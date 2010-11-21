module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL logical `or` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-logical-or
    # @see http://www.w3.org/TR/rdf-sparql-query/#evaluation
    class Or < Operator::Binary
      NAME = [:or, :'||']

      ##
      # Returns the logical `OR` of the left operand and the right operand.
      #
      # Note that this operator operates on the effective boolean value
      # (EBV) of its operands.
      #
      # @param  [RDF::Query::Solution, #[]] bindings
      # @return [RDF::Literal::Boolean]
      # @raise  [TypeError] if the operands could not be coerced to `RDF::Literal::Boolean`
      def evaluate(bindings = {})
        lhs = lambda { boolean(operand(0).evaluate(bindings)).true? }
        rhs = lambda { boolean(operand(1).evaluate(bindings)).true? }
        RDF::Literal(lhs.call || rhs.call) # FIXME: error handling
      end
    end # Or
  end # Operator
end; end # SPARQL::Algebra

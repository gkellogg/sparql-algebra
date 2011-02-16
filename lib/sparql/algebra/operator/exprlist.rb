module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL GraphPattern `exprlist` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#evaluation
    class Exprlist < Operator
      NAME = [:exprlist]

      ##
      # Returns the logical `OR` of the left operand and the right operand.
      #
      # Note that this operator operates on the effective boolean value
      # (EBV) of its operands.
      #
      # @param  [RDF::Query::Solution, #[]] bindings
      # @return [RDF::Literal::Boolean] `true` or `false`
      # @raise  [TypeError] if the operands could not be coerced to a boolean literal
      def evaluate(bindings = {})
        res = operands.all? {|op| boolean(op.evaluate(bindings)).true? }
        RDF::Literal(res) # FIXME: error handling
      end

      ##
      # Returns an optimized version of this query.
      #
      # Return optimized query
      #
      # @return [Union, RDF::Query] `self`
      def optimize
        operands = operands.map(&:optimize)
      end
    end # Exprlist
  end # Operator
end; end # SPARQL::Algebra

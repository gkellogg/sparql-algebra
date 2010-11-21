module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL logical `and` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-logical-and
    # @see http://www.w3.org/TR/rdf-sparql-query/#evaluation
    class And < Operator::Binary
      NAME = [:and, :'&&']

      ##
      # Returns the logical `AND` of the left operand and the right operand.
      #
      # Note that this operator operates on the effective boolean value
      # (EBV) of its operands.
      #
      # @param  [RDF::Query::Solution] solution
      # @return [RDF::Literal::Boolean]
      # @raise  [TypeError] if the operands could not be coerced to `RDF::Literal::Boolean`
      def evaluate(solution)
        lhs = lambda { boolean(operand(0, solution)).true? }
        rhs = lambda { boolean(operand(1, solution)).true? }
        RDF::Literal(lhs.call && rhs.call) # FIXME: error handling
      end
    end # And
  end # Operator
end; end # SPARQL::Algebra

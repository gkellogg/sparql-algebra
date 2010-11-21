module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL logical `not` operator.
    #
    # @see http://www.w3.org/TR/xpath-functions/#func-not
    class Not < Operator::Unary
      NAME = [:not, :'!']

      ##
      # Returns the logical `NOT` (inverse) of the operand.
      #
      # Note that this operator operates on the effective boolean value
      # (EBV) of its operand.
      #
      # @param  [RDF::Query::Solution] solution
      # @return [RDF::Literal::Boolean]
      # @raise  [TypeError] if the operand could not be coerced to an `RDF::Literal::Boolean`
      def evaluate(solution)
        case bool = boolean(operand(0, solution))
          when RDF::Literal::Boolean
            RDF::Literal(bool.false?)
          else super
        end
      end
    end # Not
  end # Operator
end; end # SPARQL::Algebra

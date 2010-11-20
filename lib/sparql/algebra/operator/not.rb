module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL unary `!` operator.
    #
    # @see http://www.w3.org/TR/xpath-functions/#func-not
    class Not < Operator::Unary
      NAME = [:not, :'!']

      ##
      # Returns `true` if the effective boolean value of the operand is
      # `false`, and `false` otherwise.
      #
      # If the operand is not an `xsd:boolean`, it is coerced to one by
      # evaluating the effective boolean value (EBV) of the operand.
      #
      # @param  [RDF::Query::Solution] solution
      # @return [RDF::Literal::Boolean]
      # @raise  [TypeError] if the operand could not be coerced to an `RDF::Literal::Boolean`
      def evaluate(solution)
        case bool = boolean(operands.first) # TODO: variable lookup
          when RDF::Literal::Boolean
            RDF::Literal(bool.false?)
          else super
        end
      end
    end # Not
  end # Operator
end; end # SPARQL::Algebra

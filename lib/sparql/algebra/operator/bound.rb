module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL `bound` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-bound
    class Bound < Operator::Unary
      NAME = :bound

      ##
      # Returns `true` if the operand is a variable that is bound to a
      # value in the given `solution`, `false` otherwise.
      #
      # @param  [RDF::Query::Solution] solution
      # @return [RDF::Literal::Boolean] `true` or `false`
      # @raise  [TypeError] if the operand is not an `RDF::Query::Variable`
      def evaluate(solution)
        case var = operands.first
          when Variable, Symbol
            RDF::Literal(solution.bound?(var))
          else raise TypeError, "expected an RDF::Query::Variable, but got #{var.inspect}"
        end
      end
    end # Bound
  end # Operator
end; end # SPARQL::Algebra

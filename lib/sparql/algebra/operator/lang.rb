module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL `lang` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-lang
    class Lang < Operator::Unary
      NAME = :lang

      ##
      # Returns the language tag of the operand, if it has one.
      #
      # If the operand has no language tag, returns `""`.
      #
      # @param  [RDF::Query::Solution] solution
      # @return [RDF::Literal] a simple literal
      # @raise  [ArgumentError] if the operand is not an `RDF::Literal`
      def evaluate(solution)
        case literal = operands.first # TODO: variable lookup
          when RDF::Literal then RDF::Literal(literal.language.to_s)
          else raise ArgumentError, "expected an RDF::Literal, but got #{literal.inspect}"
        end
      end
    end # Lang
  end # Operator
end; end # SPARQL::Algebra
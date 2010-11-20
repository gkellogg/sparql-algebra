module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL `str` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-str
    class Str < Operator::Unary
      NAME = :str

      ##
      # Returns the string form of the argument.
      #
      # @param  [RDF::Query::Solution] solution
      # @return [RDF::Literal] a simple literal
      # @raise  [ArgumentError] if the argument is not an `RDF::Literal` or `RDF::URI`
      def evaluate(solution)
        case term = arguments.first
          when RDF::Literal then RDF::Literal(term.value)
          when RDF::URI     then RDF::Literal(term.to_s)
          else raise ArgumentError, "expected RDF::Literal or RDF::URI, but got #{term.inspect}"
        end
      end
    end # Str
  end # Operator
end; end # SPARQL::Algebra

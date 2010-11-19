module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL `str` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-str
    class Str < Operator::Unary
      ##
      # Returns the string form of `term`.
      #
      # @overload evaluate(RDF::Literal)
      #   Returns the lexical form of the given literal.
      #   
      #   @param  [RDF::Literal] term an RDF literal
      #   @return [RDF::Literal] a plain literal
      #
      # @overload evaluate(RDF::URI)
      #   Returns the codepoint representation of the given IRI.
      #   
      #   @param  [RDF::URI] term an RDF URI
      #   @return [RDF::Literal] a plain literal
      #
      # @return [RDF::Literal]
      def evaluate(term)
        case term
          when RDF::Literal then RDF::Literal(term.value)
          when RDF::URI     then RDF::Literal(term.to_s)
          else raise ArgumentError, "expected RDF::Literal or RDF::URI, but got #{term.inspect}"
        end
      end
    end # Str
  end # Operator
end; end # SPARQL::Algebra

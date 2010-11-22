module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL `str` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-str
    class Str < Operator::Unary
      NAME = :str

      ##
      # Initializes a new operator instance.
      #
      # @param  [RDF::Literal, RDF::URI] term
      #   an RDF literal or IRI
      # @param  [Hash{Symbol => Object}] options
      #   any additional options (see {Operator#initialize})
      # @raise  [TypeError] if any operand is invalid
      def initialize(term, options = {})
        super(term, options)
      end

      ##
      # Returns the string form of the operand.
      #
      # @param  [RDF::Query::Solution, #[]] bindings
      # @return [RDF::Literal] a simple literal
      # @raise  [TypeError] if the operand is not an `RDF::Literal` or `RDF::URI`
      def evaluate(bindings = {})
        case term = operand.evaluate(bindings)
          when RDF::Literal then RDF::Literal(term.value)
          when RDF::URI     then RDF::Literal(term.to_s)
          else raise TypeError, "expected an RDF::Literal or RDF::URI, but got #{term.inspect}"
        end
      end
    end # Str
  end # Operator
end; end # SPARQL::Algebra

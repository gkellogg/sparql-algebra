module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL `lang` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-lang
    class Lang < Operator::Unary
      NAME = :lang

      ##
      # Initializes a new operator instance.
      #
      # @param  [RDF::Literal] literal
      #   an RDF literal
      # @param  [Hash{Symbol => Object}] options
      #   any additional options (see {Operator#initialize})
      # @raise  [TypeError] if any operand is invalid
      def initialize(literal, options = {})
        super(literal, options)
      end

      ##
      # Returns the language tag of the operand, if it has one.
      #
      # If the operand has no language tag, returns `""`.
      #
      # @param  [RDF::Query::Solution, #[]] bindings
      # @return [RDF::Literal] a simple literal
      # @raise  [TypeError] if the operand is not an `RDF::Literal`
      def evaluate(bindings = {})
        case literal = operand.evaluate(bindings)
          when RDF::Literal then RDF::Literal(literal.language.to_s)
          else raise TypeError, "expected an RDF::Literal, but got #{literal.inspect}"
        end
      end
    end # Lang
  end # Operator
end; end # SPARQL::Algebra

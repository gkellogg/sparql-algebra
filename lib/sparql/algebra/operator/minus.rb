module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL numeric unary `-` (negation) operator.
    #
    # @see http://www.w3.org/TR/xpath-functions/#func-numeric-unary-minus
    class Minus < Operator::Unary
      NAME = [:-, :minus]

      ##
      # Initializes a new operator instance.
      #
      # @param  [RDF::Literal::Numeric] numeric
      #   a numeric RDF literal
      # @param  [Hash{Symbol => Object}] options
      #   any additional options (see {Operator#initialize})
      # @raise  [TypeError] if any operand is invalid
      def initialize(numeric, options = {})
        super(numeric, options)
      end

      ##
      # Returns the operand with its sign reversed.
      #
      # @param  [RDF::Query::Solution, #[]] bindings
      # @return [RDF::Literal::Numeric]
      # @raise  [TypeError] if the operand is not an `RDF::Literal::Numeric`
      def evaluate(bindings = {})
        case term = operand.evaluate(bindings)
          when RDF::Literal::Numeric then -term
          else raise TypeError, "expected an RDF::Literal::Numeric, but got #{term.inspect}"
        end
      end
    end # Minus
  end # Operator
end; end # SPARQL::Algebra

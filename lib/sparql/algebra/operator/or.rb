module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL logical `or` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-logical-or
    # @see http://www.w3.org/TR/rdf-sparql-query/#evaluation
    class Or < Operator::Binary
      NAME = [:or, :'||']

      ##
      # Initializes a new operator instance.
      #
      # @param  [RDF::Literal::Boolean] left
      #   the left operand
      # @param  [RDF::Literal::Boolean] right
      #   the right operand
      # @param  [Hash{Symbol => Object}] options
      #   any additional options (see {Operator#initialize})
      # @raise  [TypeError] if any operand is invalid
      def initialize(left, right, options = {})
        super
      end

      ##
      # Returns the logical `OR` of the left operand and the right operand.
      #
      # Note that this operator operates on the effective boolean value
      # (EBV) of its operands.
      #
      # @param  [RDF::Query::Solution, #[]] bindings
      # @return [RDF::Literal::Boolean] `true` or `false`
      # @raise  [TypeError] if the operands could not be coerced to a boolean literal
      def evaluate(bindings = {})
        left  = lambda { boolean(operand(0).evaluate(bindings)).true? }
        right = lambda { boolean(operand(1).evaluate(bindings)).true? }
        RDF::Literal(left.call || right.call) # FIXME: error handling
      end
    end # Or
  end # Operator
end; end # SPARQL::Algebra

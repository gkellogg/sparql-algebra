module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL logical `and` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-logical-and
    # @see http://www.w3.org/TR/rdf-sparql-query/#evaluation
    class And < Operator::Binary
      NAME = [:and, :'&&']

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
        super(left, right, options)
      end

      ##
      # Returns the logical `AND` of the left operand and the right operand.
      #
      # Note that this operator operates on the effective boolean value
      # (EBV) of its operands.
      #
      # @param  [RDF::Query::Solution, #[]] bindings
      # @return [RDF::Literal::Boolean]
      # @raise  [TypeError] if the operands could not be coerced to `RDF::Literal::Boolean`
      def evaluate(bindings = {})
        left  = lambda { boolean(operand(0).evaluate(bindings)).true? }
        right = lambda { boolean(operand(1).evaluate(bindings)).true? }
        RDF::Literal(left.call && right.call) # FIXME: error handling
      end
    end # And
  end # Operator
end; end # SPARQL::Algebra

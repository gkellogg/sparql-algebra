module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL numeric `divide` operator.
    #
    # @see http://www.w3.org/TR/xpath-functions/#func-numeric-divide
    class Divide < Operator::Binary
      NAME = [:'/', :divide]

      ##
      # Initializes a new operator instance.
      #
      # @param  [RDF::Literal::Numeric] left
      #   a numeric RDF literal
      # @param  [RDF::Literal::Numeric] right
      #   a numeric RDF literal
      # @param  [Hash{Symbol => Object}] options
      #   any additional options (see {Operator#initialize})
      # @raise  [TypeError] if any operand is invalid
      def initialize(left, right, options = {})
        super
      end

      ##
      # Returns the arithmetic quotient of the operands.
      #
      # @param  [RDF::Query::Solution, #[]] bindings
      # @return [RDF::Literal::Numeric]
      # @raise  [TypeError] if either operand is not an `RDF::Literal::Numeric`
      def evaluate(bindings = {})
        left  = operand(0).evaluate(bindings)
        right = operand(1).evaluate(bindings)
        case
          when left.is_a?(RDF::Literal::Numeric) && right.is_a?(RDF::Literal::Numeric)
            # For xsd:decimal and xsd:integer operands, if the divisor is
            # (positive or negative) zero, an error is raised.
            raise ZeroDivisionError, "divided by #{right}" if left.is_a?(RDF::Literal::Decimal) && right.zero?

            # As a special case, if the types of both operands are
            # xsd:integer, then the return type is xsd:decimal.
            if left.is_a?(RDF::Literal::Integer) && right.is_a?(RDF::Literal::Integer)
              RDF::Literal(left.to_d / right.to_d)
            else
              left / right
            end
          else raise TypeError, "expected two RDF::Literal::Numeric operands, but got #{left.inspect} and #{right.inspect}"
        end
      end
    end # Divide
  end # Operator
end; end # SPARQL::Algebra

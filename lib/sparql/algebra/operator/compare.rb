module SPARQL; module Algebra
  class Operator
    ##
    # A (non-standard) SPARQL relational `<=>` comparison operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#OperatorMapping
    # @see http://www.w3.org/TR/xpath-functions/#func-compare
    class Compare < Operator::Binary
      NAME = :<=>

      ##
      # Returns -1, 0, or 1, depending on whether the first operand is
      # respectively less than, equal to, or greater than the second
      # operand.
      #
      # SPARQL also fixes an order between some kinds of RDF terms that would not otherwise be ordered:
      #
      #   (Lowest) no value assigned to the variable or expression in this solution.
      #   Blank nodes
      #   IRIs
      #   RDF literals
      #
      # @param  [RDF::Literal] left
      #   a literal
      # @param  [RDF::Literal] right
      #   a literal
      # @return [RDF::Literal::Integer] `-1`, `0`, or `1`
      # @raise  [TypeError] if either operand is not a literal
      def apply(left, right)
        case
        # @see http://www.w3.org/TR/rdf-sparql-query/#OperatorMapping
        # @see http://www.w3.org/TR/rdf-sparql-query/#modOrderBy
        when left.is_a?(RDF::Literal) && right.is_a?(RDF::Literal)
          case
          # @see http://www.w3.org/TR/xpath-functions/#string-compare
          # @see http://www.w3.org/TR/xpath-functions/#comp.numeric
          # @see http://www.w3.org/TR/xpath-functions/#op.boolean
          # @see http://www.w3.org/TR/xpath-functions/#comp.duration.datetime
          when (left.simple? && right.simple?) ||
               (left.datatype.eql?(RDF::XSD.string) && right.datatype.eql?(RDF::XSD.string)) ||
               (left.is_a?(RDF::Literal::Numeric)   && right.is_a?(RDF::Literal::Numeric))   ||
               (left.is_a?(RDF::Literal::Boolean)   && right.is_a?(RDF::Literal::Boolean))   ||
               (left.is_a?(RDF::Literal::DateTime)  && right.is_a?(RDF::Literal::DateTime))
            RDF::Literal(left.send(self.class.const_get(:NAME), right))

          else raise TypeError, "unable to compare #{left.inspect} and #{right.inspect}"
          end
          
        when left.is_a?(RDF::URI) && right.is_a?(RDF::URI)
          # Pairs of IRIs are ordered by comparing them as simple literals.
          RDF::Literal(RDF::Literal(left.to_s).send(self.class.const_get(:NAME), RDF::Literal(right.to_s)))
        when left.is_a?(RDF::Node) && right.is_a?(RDF::Node)
          # BNode comparison is undefined.
          RDF::Literal(0)
        when left.is_a?(RDF::Node) && right.is_a?(RDF::Term)
          RDF::Literal(-1)
        when right.is_a?(RDF::Node) && left.is_a?(RDF::Term)
          RDF::Literal(1)
        when left.is_a?(RDF::URI) && right.is_a?(RDF::Term)
          RDF::Literal(-1)
        when right.is_a?(RDF::URI) && left.is_a?(RDF::Term)
          RDF::Literal(1)
        else raise TypeError, "expected two RDF::Term operands, but got #{left.inspect} and #{right.inspect}"
        end
      end
    end # Compare
  end # Operator
end; end # SPARQL::Algebra

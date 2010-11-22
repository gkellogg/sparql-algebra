module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL relational `=` (equal) comparison operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#OperatorMapping
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-RDFterm-equal
    class Equal < Operator::Binary
      NAME = :'='

      ##
      # Initializes a new operator instance.
      #
      # @param  [RDF::Term] term1
      #   an RDF term
      # @param  [RDF::Term] term2
      #   an RDF term
      # @param  [Hash{Symbol => Object}] options
      #   any additional options (see {Operator#initialize})
      # @raise  [TypeError] if any operand is invalid
      def initialize(term1, term2, options = {})
        super(term1, term2, options)
      end

      ##
      # Returns `true` if the operands are equal; returns `false` otherwise.
      #
      # @param  [RDF::Query::Solution, #[]] bindings
      # @return [RDF::Literal::Boolean]
      # @raise  [TypeError] if either operand is not an RDF term
      def evaluate(bindings = {})
        term1, term2 = operand(0).evaluate(bindings), operand(1).evaluate(bindings)
        case
          # @see http://www.w3.org/TR/rdf-sparql-query/#OperatorMapping
          when term1.is_a?(RDF::Literal) && term2.is_a?(RDF::Literal) then case
            # @see http://www.w3.org/TR/xpath-functions/#func-compare
            # @see http://www.w3.org/TR/xpath-functions/#func-numeric-equal
            # @see http://www.w3.org/TR/xpath-functions/#func-boolean-equal
            # @see http://www.w3.org/TR/xpath-functions/#func-dateTime-equal
            when (term1.simple? && term2.simple?) ||
                 (term1.datatype.eql?(RDF::XSD.string) && term2.datatype.eql?(RDF::XSD.string)) ||
                 (term1.is_a?(RDF::Literal::Numeric)   && term2.is_a?(RDF::Literal::Numeric)) ||
                 (term1.is_a?(RDF::Literal::Boolean)   && term2.is_a?(RDF::Literal::Boolean)) ||
                 (term1.is_a?(RDF::Literal::DateTime)  && term2.is_a?(RDF::Literal::DateTime))
              RDF::Literal(!!(term1 == term2))

            # @see http://www.w3.org/TR/rdf-sparql-query/#func-RDFterm-equal
            when term1.eql?(term2)
              RDF::Literal::TRUE

            else raise TypeError, "unable to determine whether #{term1.inspect} and #{term2.inspect} are equivalent"
          end

          # @see http://www.w3.org/TR/rdf-concepts/#section-Graph-URIref
          # @see http://www.w3.org/TR/rdf-concepts/#section-blank-nodes
          when (term1.is_a?(RDF::URI)  && term2.is_a?(RDF::URI)) ||
               (term1.is_a?(RDF::Node) && term2.is_a?(RDF::Node))
            RDF::Literal(term1.eql?(term2))

          # @see http://www.w3.org/TR/rdf-sparql-query/#func-RDFterm-equal
          when term1.is_a?(RDF::Term) && term2.is_a?(RDF::Term)
            RDF::Literal::FALSE

          else raise TypeError, "expected two RDF::Term operands, but got #{term1.inspect} and #{term2.inspect}"
        end
      end
    end # Equal
  end # Operator
end; end # SPARQL::Algebra

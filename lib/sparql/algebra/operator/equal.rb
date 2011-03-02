module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL relational `=` (equal) comparison operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#OperatorMapping
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-RDFterm-equal
    class Equal < Compare
      NAME = :'='

      ##
      # Returns `true` if the operands are equal; returns `false` otherwise.
      #
      # @param  [RDF::Term] term1
      #   an RDF term
      # @param  [RDF::Term] term2
      #   an RDF term
      # @return [RDF::Literal::Boolean] `true` or `false`
      # @raise  [TypeError] if either operand is not an RDF term
      def apply(term1, term2)
        case
          # @see http://www.w3.org/TR/rdf-sparql-query/#OperatorMapping
          when term1.is_a?(RDF::Literal) && term2.is_a?(RDF::Literal) then case
            # @see http://www.w3.org/TR/xpath-functions/#func-compare
            # @see http://www.w3.org/TR/xpath-functions/#func-numeric-equal
            # @see http://www.w3.org/TR/xpath-functions/#func-boolean-equal
            # @see http://www.w3.org/TR/xpath-functions/#func-dateTime-equal
            when (term1.simple? && term2.simple?) ||
                 (term1.datatype.eql?(RDF::XSD.string) && term2.datatype.eql?(RDF::XSD.string)) ||
                 (term1.is_a?(RDF::Literal::Numeric)   && term2.is_a?(RDF::Literal::Numeric))   ||
                 (term1.is_a?(RDF::Literal::Boolean)   && term2.is_a?(RDF::Literal::Boolean))   ||
                 (term1.is_a?(RDF::Literal::Date)      && term2.is_a?(RDF::Literal::Date))      ||
                 (term1.is_a?(RDF::Literal::Time)     && term2.is_a?(RDF::Literal::Time))       ||
                 (term1.is_a?(RDF::Literal::DateTime)  && term2.is_a?(RDF::Literal::DateTime))
              # If the lexical form is not in the lexical space of the datatype associated
              # with the datatype URI, then no literal value can be associated with the typed literal.
              # Such a case, while in error, is not syntactically ill-formed.
              # @see http://www.w3.org/TR/rdf-concepts/#section-Literal-Equality
              RDF::Literal(!!(term1 == term2) && term1.valid? && term2.valid?)

            when [RDF::Literal::Date, RDF::Literal::Time, RDF::Literal::DateTime].include?(term1.class) &&
                 [RDF::Literal::Date, RDF::Literal::Time, RDF::Literal::DateTime].include?(term2.class)
              # Special case for xs:date and xs:time comparisons with xs:dateTime, they don't
              # generate an error, but they don't compare otherwise
              RDF::Literal::FALSE

            # If literals are syntactically equivalent
            # @see http://www.w3.org/TR/rdf-sparql-query/#func-RDFterm-equal
            when term1.eql?(term2)
              RDF::Literal::TRUE

            # Numerics and DateTimes can't be compared with other terms
            when term1.is_a?(RDF::Literal::Boolean) ||
                 term1.is_a?(RDF::Literal::Numeric) ||
                 term1.is_a?(RDF::Literal::Date) ||
                 term1.is_a?(RDF::Literal::Time) ||
                 term1.is_a?(RDF::Literal::DateTime) ||
                 term2.is_a?(RDF::Literal::Boolean) ||
                 term2.is_a?(RDF::Literal::Numeric) ||
                 term2.is_a?(RDF::Literal::Date) ||
                 term2.is_a?(RDF::Literal::Time) ||
                 term2.is_a?(RDF::Literal::DateTime)
              raise TypeError, "can't compare #{term1.inspect} and #{term2.inspect}"

            # If one of the terms is untyped, check for equivalence with an unknown typed term
            # Fixme: not sure where this is defined, but implied by data-r2/expr-equal/eq-2-2
            when term2.simple? && term1.has_datatype? && term1.datatype != RDF::XSD.string ||
                 term1.simple? && term2.has_datatype? && term2.datatype != RDF::XSD.string
              RDF::Literal::FALSE

            # produces a type error if the arguments are both literal but are not the same RDF term
            # @see http://www.w3.org/TR/rdf-sparql-query/#func-RDFterm-equal
            else raise TypeError, "unable to determine whether #{term1.inspect} and #{term2.inspect} are equivalent"
          end

          # Numerics and DateTimes can't be compared with other terms
          when term1.is_a?(RDF::Literal::Boolean) ||
               term1.is_a?(RDF::Literal::Numeric) ||
               term1.is_a?(RDF::Literal::Date) ||
               term1.is_a?(RDF::Literal::Time) ||
               term1.is_a?(RDF::Literal::DateTime) ||term1.is_a?(RDF::Literal::Boolean) ||
               term2.is_a?(RDF::Literal::Numeric) ||
               term2.is_a?(RDF::Literal::Date) ||
               term2.is_a?(RDF::Literal::Time) ||
               term2.is_a?(RDF::Literal::DateTime)
            raise TypeError, "can't compare #{term1.inspect} and #{term2.inspect}"

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

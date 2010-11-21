module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL `langMatches` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-langMatches
    # @see http://tools.ietf.org/html/rfc4647#section-3.3.1
    class LangMatches < Operator::Binary
      NAME = :langMatches

      ##
      # Returns `true` if the language tag (the first operand) matches the
      # language range (the second operand).
      #
      # @param  [RDF::Query::Solution, #[]] bindings
      # @return [RDF::Literal::Boolean]
      # @raise  [TypeError] if either operand is unbound
      # @raise  [TypeError] if either operand is not a plain `RDF::Literal`
      def evaluate(bindings = {})
        lhs = operand(0).evaluate(bindings)
        raise TypeError, "expected a plain RDF::Literal, but got #{lhs.inspect}" unless lhs.is_a?(RDF::Literal) && lhs.plain?
        lhs = lhs.to_s.downcase

        rhs = operand(1).evaluate(bindings)
        raise TypeError, "expected a plain RDF::Literal, but got #{rhs.inspect}" unless rhs.is_a?(RDF::Literal) && rhs.plain?
        rhs = rhs.to_s.downcase

        case
          # A language range of "*" matches any non-empty language tag.
          when rhs.eql?('*')
            RDF::Literal(!(lhs.empty?))
          # A language range matches a particular language tag if, in a
          # case-insensitive comparison, it exactly equals the tag, ...
          when lhs.eql?(rhs)
            RDF::Literal::TRUE
          # ... or if it exactly equals a prefix of the tag such that the
          # first character following the prefix is "-".
          else
            RDF::Literal(lhs.start_with?(rhs + '-'))
        end
      end
    end # LangMatches
  end # Operator
end; end # SPARQL::Algebra

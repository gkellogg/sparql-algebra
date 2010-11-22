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
      # Initializes a new operator instance.
      #
      # @param  [RDF::Literal] language_tag
      #   a simple RDF literal containing a language tag
      # @param  [RDF::Literal] language_range
      #   a simple RDF literal containing a language range, per
      #   [RFC 4647 section 2.1](http://tools.ietf.org/html/rfc4647#section-2.1)
      # @param  [Hash{Symbol => Object}] options
      #   any additional options (see {Operator#initialize})
      # @raise  [TypeError] if any operand is invalid
      def initialize(language_tag, language_range, options = {})
        super(language_tag, language_range, options)
      end

      ##
      # Returns `true` if the language tag (the first operand) matches the
      # language range (the second operand).
      #
      # @param  [RDF::Query::Solution, #[]] bindings
      # @return [RDF::Literal::Boolean]
      # @raise  [TypeError] if either operand is unbound
      # @raise  [TypeError] if either operand is not a plain `RDF::Literal`
      def evaluate(bindings = {})
        language_tag = operand(0).evaluate(bindings)
        raise TypeError, "expected a plain RDF::Literal, but got #{language_tag.inspect}" unless language_tag.is_a?(RDF::Literal) && language_tag.plain?
        language_tag = language_tag.to_s.downcase

        language_range = operand(1).evaluate(bindings)
        raise TypeError, "expected a plain RDF::Literal, but got #{language_range.inspect}" unless language_range.is_a?(RDF::Literal) && language_range.plain?
        language_range = language_range.to_s.downcase

        case
          # A language range of "*" matches any non-empty language tag.
          when language_range.eql?('*')
            RDF::Literal(!(language_tag.empty?))
          # A language range matches a particular language tag if, in a
          # case-insensitive comparison, it exactly equals the tag, ...
          when language_tag.eql?(language_range)
            RDF::Literal::TRUE
          # ... or if it exactly equals a prefix of the tag such that the
          # first character following the prefix is "-".
          else
            RDF::Literal(language_tag.start_with?(language_range + '-'))
        end
      end
    end # LangMatches
  end # Operator
end; end # SPARQL::Algebra

module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL `regex` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#funcex-regex
    # @see http://www.w3.org/TR/xpath-functions/#func-matches
    class Regex < Operator::Ternary
      NAME = :regex

      ##
      # Initializes a new operator instance.
      #
      # @param  [RDF::Literal] text
      #   a simple RDF literal
      # @param  [RDF::Literal] pattern
      #   a simple RDF literal
      # @param  [RDF::Literal] flags
      #   a simple RDF literal (defaults to an empty string)
      # @param  [Hash{Symbol => Object}] options
      #   any additional options (see {Operator#initialize})
      # @raise  [TypeError] if any operand is invalid
      def initialize(text, pattern, flags = RDF::Literal(''), options = {})
        super
      end

      ##
      # Matches `text` against a regular expression `pattern`.
      #
      # @param  [RDF::Query::Solution, #[]] bindings
      # @return [RDF::Literal::Boolean]
      # @raise  [TypeError] if any operand is unbound
      # @raise  [TypeError] if any operand is not a simple RDF literal
      def evaluate(bindings = {})
        # @see http://www.w3.org/TR/xpath-functions/#regex-syntax
        text = operand(0).evaluate(bindings)
        raise TypeError, "expected a plain RDF::Literal, but got #{text.inspect}" unless text.is_a?(RDF::Literal) && text.plain?
        text = text.to_s
        # TODO: validate text syntax

        # @see http://www.w3.org/TR/xpath-functions/#regex-syntax
        pattern = operand(1).evaluate(bindings)
        raise TypeError, "expected a plain RDF::Literal, but got #{pattern.inspect}" unless pattern.is_a?(RDF::Literal) && pattern.plain?
        pattern = pattern.to_s
        # TODO: validate pattern syntax

        # @see http://www.w3.org/TR/xpath-functions/#flags
        flags = operand(2).evaluate(bindings)
        raise TypeError, "expected a plain RDF::Literal, but got #{flags.inspect}" unless flags.is_a?(RDF::Literal) && flags.plain?
        flags = flags.to_s
        # TODO: validate flag syntax

        options = 0
        raise NotImplementedError, "unsupported regular expression flag: /s" if flags.include?(?s) # FIXME
        options |= Regexp::MULTILINE  if flags.include?(?m)
        options |= Regexp::IGNORECASE if flags.include?(?i)
        options |= Regexp::EXTENDED   if flags.include?(?x)
        RDF::Literal(Regexp.new(pattern, options) === text)
      end
    end # Regex
  end # Operator
end; end # SPARQL::Algebra

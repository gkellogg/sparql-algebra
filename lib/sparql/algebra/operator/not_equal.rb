module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL relational `!=` (not equal) comparison operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#OperatorMapping
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-RDFterm-equal
    class NotEqual < Equal
      NAME = :'!='

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
        super
      end

      ##
      # Returns `true` if the operands are not equal;
      # returns `false` otherwise.
      #
      # @param  [RDF::Query::Solution, #[]] bindings
      # @return [RDF::Literal::Boolean]
      # @raise  [TypeError] if either operand is not an RDF term
      def evaluate(bindings = {})
        RDF::Literal(super.false?)
      end
    end # NotEqual
  end # Operator
end; end # SPARQL::Algebra

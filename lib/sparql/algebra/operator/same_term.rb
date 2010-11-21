module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL `sameTerm` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-sameTerm
    class SameTerm < Operator::Binary
      NAME = :sameTerm

      ##
      # Initializes a new operator instance.
      #
      # @param  [RDF::Term] term1
      #   an RDF term
      # @param  [RDF::Term] term2
      #   an RDF term
      # @param  [Hash{Symbol => Object}] options
      #   any additional options (see {Operator#initialize})
      def initialize(term1, term2, options = {})
        super(term1, term2, options)
      end

      ##
      # Returns `true` if the operands are the same RDF term; returns
      # `false` otherwise.
      #
      # @param  [RDF::Query::Solution, #[]] bindings
      # @return [RDF::Literal::Boolean]
      # @raise  [TypeError] if either operand is unbound
      def evaluate(bindings = {})
        term1 = operand(0).evaluate(bindings)
        term2 = operand(1).evaluate(bindings)
        RDF::Literal(term1.eql?(term2)) # FIXME
      end
    end # SameTerm
  end # Operator
end; end # SPARQL::Algebra

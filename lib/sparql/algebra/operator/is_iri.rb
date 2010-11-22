module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL `isIRI`/`isURI` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-isIRI
    class IsIRI < Operator::Unary
      NAME = [:isIRI, :isURI]

      ##
      # Initializes a new operator instance.
      #
      # @param  [RDF::Term] term
      #   an RDF term
      # @param  [Hash{Symbol => Object}] options
      #   any additional options (see {Operator#initialize})
      # @raise  [TypeError] if any operand is invalid
      def initialize(term, options = {})
        super(term, options)
      end

      ##
      # Returns `true` if the operand is an `RDF::URI`, `false` otherwise.
      #
      # @param  [RDF::Query::Solution, #[]] bindings
      # @return [RDF::Literal::Boolean] `true` or `false`
      # @raise  [TypeError] if the operand is not an `RDF::Term`
      def evaluate(bindings = {})
        case term = operand.evaluate(bindings)
          when RDF::URI  then RDF::Literal::TRUE
          when RDF::Term then RDF::Literal::FALSE
          else raise TypeError, "expected an RDF::Term, but got #{term.inspect}"
        end
      end

      Operator::IsURI = IsIRI
    end # IsIRI
  end # Operator
end; end # SPARQL::Algebra

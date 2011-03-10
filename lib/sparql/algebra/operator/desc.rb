module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL descending sort operator.
    #
    # @example
    #   (prefix ((foaf: <http://xmlns.com/foaf/0.1/>))
    #     (project (?name)
    #       (order ((desc ?name))
    #         (bgp (triple ?x foaf:name ?name)))))
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-isLiteral
    class Desc < Operator::Unary
      include Evaluatable

      NAME = :desc

      ##
      # Returns the evaluation of it's operand. Default comparison is in
      # ascending order. Ordering is applied in {Order}.
      #
      # @param  [RDF::Query::Solution, #[]] bindings
      # @return [RDF::Term]
      def evaluate(bindings = {})
        operand(0).evaluate(bindings)
      end
    end # Desc
  end # Operator
end; end # SPARQL::Algebra

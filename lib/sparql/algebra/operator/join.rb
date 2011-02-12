module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL GraphPattern `join` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#sparqlAlgebra
    class Join < Operator
      include Query
      
      NAME = [:join]

      ##
      # Executes this query on the given `queryable` graph or repository.
      #
      # @param  [RDF::Queryable] queryable
      #   the graph or repository to query
      # @param  [Hash{Symbol => Object}] options
      #   any additional keyword options
      # @return [RDF::Query::Solutions]
      #   the resulting solution sequence
      # @see    http://www.w3.org/TR/rdf-sparql-query/#sparqlAlgebra
      #
      #     D : a dataset
      #     D(G) : D a dataset with active graph G (the one patterns match against)
      #     D[i] : The graph with IRI i in dataset D
      #     D[DFT] : the default graph of D
      #     P, P1, P2 : graph patterns
      #     L : a solution sequence
      def execute(queryable, options = {})
        # Join(Ω1, Ω2) = { merge(μ1, μ2) | μ1 in Ω1 and μ2 in Ω2, and μ1 and μ2 are compatible }
        # eval(D(G), Join(P1, P2)) = Join(eval(D(G), P1), eval(D(G), P2))
      end
      
      ##
      # Returns an optimized version of this query.
      #
      # Groups of one graph pattern (not a filter) become join(Z, A) and can be replaced by A.
      # The empty graph pattern Z is the identity for join:
      #   Replace join(Z, A) by A
      #   Replace join(A, Z) by A
      #
      # @return [Join, RDF::Query] `self`
      def optimize
        ops = operands.map {|o| o.optimize }.select {|o| o.respond_to?(:empty?) && !o.empty?}
        @operands = ops
        self
      end
    end # Join
  end # Operator
end; end # SPARQL::Algebra

module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL GraphPattern `union` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#sparqlAlgebra
    class Union < Operator
      include Query
      
      NAME = [:union]

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
        # Let Ω1 and Ω2 be multisets of solution mappings. We define:
        # Union(Ω1, Ω2) = { μ | μ in Ω1 or μ in Ω2 }
        # card[Union(Ω1, Ω2)](μ) = card[Ω1](μ) + card[Ω2](μ)
        # eval(D(G), Union(P1,P2)) = Union(eval(D(G), P1), eval(D(G), P2)
        debug("Union", options)
        solutions1 = operand(0).execute(queryable, options.merge(:depth => options[:depth].to_i + 1))
        debug("=>(left) #{solutions1.inspect}", options)
        solutions2 = operand(1).execute(queryable, options.merge(:depth => options[:depth].to_i + 1))
        @solutions = RDF::Query::Solutions.new(solutions1 + solutions2)
        debug("=> #{@solutions.inspect}", options)
        @solutions
      end
      
      ##
      # Returns an optimized version of this query.
      #
      # If optimize operands, and if the first two operands are both Queries, replace
      # with the unique sum of the query elements
      #
      # @return [Union, RDF::Query] `self`
      def optimize
        ops = operands.map {|o| o.optimize }.select {|o| o.respond_to?(:empty?) && !o.empty?}
        @operands = ops
        self
      end
    end # Union
  end # Operator
end; end # SPARQL::Algebra

module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL GraphPattern `leftJoin` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#sparqlAlgebra
    class LeftJoin < Operator
      include Query
      
      NAME = [:leftjoin]

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
        # Let Ω1 and Ω2 be multisets of solution mappings and expr be an expression. We define:
        # LeftJoin(Ω1, Ω2, expr) = Filter(expr, Join(Ω1, Ω2)) set-union Diff(Ω1, Ω2, expr)
        # card[LeftJoin(Ω1, Ω2, expr)](μ) = card[Filter(expr, Join(Ω1, Ω2))](μ) + card[Diff(Ω1, Ω2, expr)](μ)
        #
        # Written in full that is:
        # LeftJoin(Ω1, Ω2, expr) =
        #     { merge(μ1, μ2) | μ1 in Ω1 and μ2 in Ω2, and μ1 and μ2 are compatible and expr(merge(μ1, μ2)) is true }
        # set-union
        #     { μ1 | μ1 in Ω1 and μ2 in Ω2, and μ1 and μ2 are not compatible }
        # set-union
        #     { μ1 | μ1 in Ω1 and μ2 in Ω2, and μ1 and μ2 are compatible and expr(merge(μ1, μ2)) is false }
        # eval(D(G), LeftJoin(P1, P2, F)) = LeftJoin(eval(D(G), P1), eval(D(G), P2), F)
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
        expr = ops.pop unless ops.last.executable?
        expr = nil if expr.respond_to?(:true?) && expr.true?
        
        # ops now is one or two executable operators
        # expr is a filter expression, which may have been optimized to 'true'
        case ops.length
        when 0
          RDF::Query.new  # Empty query, expr doesn't matter
        when 1
          expr ? Filter.new(expr, ops.first) : ops.first
        else
          expr ? LeftJoin(ops[0], ops[1], expr) : LeftJoin(ops[0], ops[1])
        end
      end
    end # LeftJoin
  end # Operator
end; end # SPARQL::Algebra

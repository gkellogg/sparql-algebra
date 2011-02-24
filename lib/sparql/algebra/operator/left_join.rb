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
        filter = operand(2)

        # Let Ω1 and Ω2 be multisets of solution mappings and expr be an expression. We define:
        # LeftJoin(Ω1, Ω2, expr) = Filter(expr, Join(Ω1, Ω2)) set-union Diff(Ω1, Ω2, expr)
        # card[LeftJoin(Ω1, Ω2, expr)](μ) = card[Filter(expr, Join(Ω1, Ω2))](μ) + card[Diff(Ω1, Ω2, expr)](μ)
        debug("LeftJoin", options)
        left = operand(0).execute(queryable, options.merge(:depth => options[:depth].to_i + 1)) || {}
        debug("=>(left) #{left.inspect}", options)
        right = operand(1).execute(queryable, options.merge(:depth => options[:depth].to_i + 1)) || {}
        debug("=>(right) #{right.inspect}", options)
        
        # LeftJoin(Ω1, Ω2, expr) =
        join_solutions = []
        left_solutions = []
        left.each do |s1|
          right.each do |s2|
            s = s2.merge(s1)
            expr = filter ? boolean(filter.evaluate(s)).true? : true rescue false
            debug("===>(evaluate) #{s.inspect}", options) if filter

            if s1.compatible?(s2)
              # { merge(μ1, μ2) | μ1 in Ω1 and μ2 in Ω2, and μ1 and μ2 are compatible and expr(merge(μ1, μ2)) is true }
              if expr
                debug("=>(merge s1 s2) #{s.inspect}", options)
                join_solutions << s

              # { μ1 | μ1 in Ω1 and μ2 in Ω2, and μ1 and μ2 are compatible and expr(merge(μ1, μ2)) is false }
              else
                debug("=>(s1 compat !filter) #{s1.inspect}", options)
                left_solutions << s1
              end
            else
              # { μ1 | μ1 in Ω1 and μ2 in Ω2, and μ1 and μ2 are not compatible }
              debug("=>(s1 !compat) #{s1.inspect}", options)
              left_solutions << s1
            end
          end
        end
        debug("(l+r)=> #{join_solutions.inspect}", options)
        debug("(l)=> #{left_solutions.inspect}", options)
        
        # Left solutions (those not being the merge between left and right)
        # are only added if there are no compatible solutions in the join list
        left_solutions.uniq.each do |l|
          next if join_solutions.any? {|j| j.compatible?(l) }
          debug("=>(add) #{l.inspect}", options)
          join_solutions << l
        end

        @solutions = RDF::Query::Solutions.new(join_solutions)
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

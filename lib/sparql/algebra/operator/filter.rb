module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL GraphPattern `filter` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#evaluation
    class Filter < Operator::Binary
      include Query
      
      NAME = [:filter]

      ##
      # Executes this query on the given `queryable` graph or repository.
      # Then it passes each solution through one or more filters
      #
      # Note that the last operand returns a solution, while the first
      # is an expression. This may be a variable, simple expression,
      # or exprlist.
      #
      # @param  [RDF::Queryable] queryable
      #   the graph or repository to query
      # @param  [Hash{Symbol => Object}] options
      #   any additional keyword options
      # @return [RDF::Query::Solutions]
      #   the resulting solution sequence
      # @see    http://www.w3.org/TR/rdf-sparql-query/#sparqlAlgebra
      # @see    http://www.w3.org/TR/rdf-sparql-query/#ebv
      def execute(queryable, options = {})
        debug("Filter #{operands.first}", options)
        @solutions = operands.last.execute(queryable, options.merge(:depth => options[:depth].to_i + 1))
        debug("=>(before) #{@solutions.inspect}", options)
        @solutions = @solutions.filter do |solution|
          # Evaluate the solution, which will return true or false
          debug("===>(evaluate) #{operands.first.inspect} against #{solution.inspect}", options)
          
          # From http://www.w3.org/TR/rdf-sparql-query/#tests
          # FILTERs eliminate any solutions that, when substituted into the expression, either
          # result in an effective boolean value of false or produce an error.
          boolean(operands.first.evaluate(solution)).true? rescue false
        end
        @solutions = RDF::Query::Solutions.new(@solutions)
        debug("=>(after) #{@solutions.inspect}", options)
        @solutions
      end
      
      ##
      # Returns an optimized version of this query.
      #
      # Return optimized query
      #
      # @return [Union, RDF::Query] `self`
      def optimize
        operands = operands.map(&:optimize)
      end
    end # Filter
  end # Operator
end; end # SPARQL::Algebra

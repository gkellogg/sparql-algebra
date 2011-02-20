module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL GraphPattern `graph` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#sparqlAlgebra
    class Graph < Operator::Binary
      include Query
      
      NAME = [:graph]

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
      def execute(queryable, options = {})
        debug("Graph", options)
        # FIXME: this must take into consideration the graph context
        @solutions = operands.last.execute(queryable, options.merge(:depth => options[:depth].to_i + 1))
        debug("=> #{@solutions.inspect}", options)
        @solutions
      end
      
      ##
      # Returns an optimized version of this query.
      #
      # Applies the context to the query operand returns the query
      #
      # @return [RDF::Query]
      def optimize
        # FIXME
        graph = operands.last.dup
        graph.context = operands.first
        graph
      end
    end # Join
  end # Operator
end; end # SPARQL::Algebra

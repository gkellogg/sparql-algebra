module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL GraphPattern `join` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#sparqlAlgebra
    class Graph < Operator
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
        operands.last.execute(queriable, options)
      end
      
      ##
      # Returns an optimized version of this query.
      #
      # Applies the context to the query operand returns the query
      #
      # @return [RDF::Query]
      def optimize
        graph = operands.last.dup
        graph.context = operands.first
        graph
      end
    end # Join
  end # Operator
end; end # SPARQL::Algebra

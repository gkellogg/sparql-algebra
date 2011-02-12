module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL GraphPattern `order` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#sparqlAlgebra
    class Project < Operator::Binary
      include Query
      
      NAME = [:project]

      ##
      # Executes this query on the given `queryable` graph or repository.
      # Really a pass-through, as this is a syntactic object used for providing
      # context for URIs.
      #
      # @param  [RDF::Queryable] queryable
      #   the graph or repository to query
      # @param  [Hash{Symbol => Object}] options
      #   any additional keyword options
      # @return [RDF::Query::Solutions]
      #   the resulting solution sequence
      # @see    http://www.w3.org/TR/rdf-sparql-query/#sparqlAlgebra
      def execute(queryable, options = {})
        @solutions = operands.last.
          execute(queriable, options = {}).
          project(operands.first)
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
    end # Project
  end # Operator
end; end # SPARQL::Algebra

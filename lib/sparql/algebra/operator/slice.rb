module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL GraphPattern `slice` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#sparqlAlgebra
    class Slice < Operator::Ternary
      include Query
      
      NAME = [:slice]

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
        @solutions = operands.last. execute(queryable, options = {})
        @solutions.offset(operands[0]) unless operands[0] == :_
        @solutions.limit(operands[1]) unless operands[1] == :_
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
    end # Slice
  end # Operator
end; end # SPARQL::Algebra

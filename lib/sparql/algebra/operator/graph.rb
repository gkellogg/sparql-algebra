module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL GraphPattern `graph` operator.
    #
    # This is basically a wrapper to add the context to the BGP.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#sparqlAlgebra
    class Graph < Operator::Binary
      NAME = [:graph]
      ##
      # A graph is an RDF::Query with a context
      def self.new(context, bgp)
        bgp.context = context
        bgp
      end
    end # Graph
  end # Operator
end; end # SPARQL::Algebra

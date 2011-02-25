module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL GraphPattern `dataset` operator.
    #
    # Instintiated with two operands, the first being an array of data source URIs,
    # either bare, indicating a default dataset, or expressed as an array [:named, <uri>],
    # indicating that it represents a named data source.
    #
    # @example
    #   (dataset (<a> (named <b>)) (bgp))
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#specifyingDataset
    class Dataset < Binary
      include Query
      
      NAME = [:dataset]

      ##
      # Executes this query on the given `queryable` graph or repository.
      # Reads specified data sources into queryable. Named data sources
      # are added using a _context_ of the data source URI.
      #
      # Datasets are specified in operand(1), which is an array of default or named graph URIs.
      #
      # @param  [RDF::Queryable] queryable
      #   the graph or repository to query
      # @param  [Hash{Symbol => Object}] options
      #   any additional keyword options
      # @return [RDF::Query::Solutions]
      #   the resulting solution sequence
      # @see    http://www.w3.org/TR/rdf-sparql-query/#sparqlAlgebra
      def execute(queryable, options = {})
        debug("Dataset", options)
        operand(0).each do |ds|
          load_opts = {}
          case ds
          when Array
            uri = self.base_uri ? self.base_uri.join(ds.last) : ds.last
            load_opts[:context] = ds.last
            debug("=> read named data source #{uri}", options)
          else
            uri = self.base_uri ? self.base_uri.join(ds) : ds
            debug("=> read default data source #{uri}", options)
          end
          queryable.load(uri.to_s, load_opts)
        end

        @solutions = operands.last.execute(queryable, options.merge(:depth => options[:depth].to_i + 1))
      end
      
      ##
      # Returns an optimized version of this query.
      #
      # If optimize operands, and if the first two operands are both Queries, replace
      # with the unique sum of the query elements
      #
      # @return [Union, RDF::Query] `self`
      def optimize
        operands.last.optimize
      end
    end # Prefix
  end # Operator
end; end # SPARQL::Algebra

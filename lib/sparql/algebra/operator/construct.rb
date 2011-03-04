module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL GraphPattern `construct` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#ask
    class Construct < Operator::Binary
      include Query
      
      NAME = [:construct]

      ##
      # Executes this query on the given {RDF::Queryable} object.
      # Binds variables to the array of patterns in the first operand and returns the resulting RDF::Graph object
      #
      # If any such instantiation produces a triple containing an unbound variable or an illegal RDF construct,
      # such as an RDF::Literal in _subject_ or _predicate_ position, then that triple is not included in the output RDF
      # graph. The graph template can contain triples with no variables (known as ground or explicit triples),
      # and these also appear in the output RDF graph returned by the CONSTRUCT query form.
      #
      # @param  [RDF::Queryable] queryable
      #   the graph or repository to query
      # @param  [Hash{Symbol => Object}] options
      #   any additional keyword options
      # @return [RDF::Query::Solutions]
      #   the resulting solution sequence
      # @see    http://www.w3.org/TR/rdf-sparql-query/#construct
      def execute(queryable, options = {})
        debug("Construct #{operands.first}, #{options.inspect}", options)
        graph = RDF::Graph.new
        patterns = operands.first
        query = operands.last

        query.execute(queryable, options.merge(:depth => options[:depth].to_i + 1)).each do |solution|
          debug("=> Apply #{solution.inspect} to BGP", options)
          
          # Create a mapping from BNodes within the pattern list to newly constructed BNodes
          nodes = {}
          patterns.each do |pattern|
            terms = {}
            [:subject, :predicate, :object].each do |r|
              terms[r] = case o = pattern.send(r)
              when RDF::Node            then nodes[o] ||= RDF::Node.new
              when RDF::Query::Variable then solution[o]
              else                           o
              end
            end
            
            statement = RDF::Statement.from(terms)

            # Sanity checking on statement
            if statement.subject.nil? || statement.predicate.nil? || statement.object.nil? ||
               statement.subject.literal? || statement.predicate.literal?
              debug("==> skip #{statement.inspect}", options)
              next
            end

            debug("==> add #{statement.inspect}", options)
            graph << statement
          end
        end
        
        debug("=> #{graph.dump(:n3)}", options)
        graph
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
    end # Construct
  end # Operator
end; end # SPARQL::Algebra

require 'json'

##
# Extensions for Ruby's `Object` class.
class Object
  ##
  # Returns the SXP representation of this object, defaults to `self'.
  #
  # @return [String]
  def to_sse
    self
  end
end

##
# Extensions for Ruby's `Object` class.
class Array
  ##
  # Returns the SXP representation of this object, defaults to `self'.
  #
  # @return [String]
  def to_sse
    map {|x| x.to_sse}
  end
  
  ##
  # Evaluates the array using the given variable `bindings`.
  #
  # In this case, the Array has two elements, the first of which is
  # an XSD datatype, and the second is the expression to be evaluated.
  # The result is cast as a literal of the appropriate type
  #
  # @param  [RDF::Query::Solution, #[]] bindings
  #   a query solution containing zero or more variable bindings
  # @return [RDF::Term]
  def evaluate(bindings)
    dt, val = self.map {|o| o.evaluate(bindings)}
    SPARQL::Algebra::Expression.cast(*self.map {|o| o.evaluate(bindings)})
  end
end

##
# Extensions for `RDF::Term`.
module RDF::Term
  include SPARQL::Algebra::Expression
  
  def evaluate(bindings)
    self
  end
end # RDF::Term

# Override RDF::Queryable to execute against SPARQL::Algebra::Query elements as well as RDF::Query and RDF::Pattern
module RDF::Queryable
  alias_method :query_without_sparql, :query
  ##
  # Queries `self` for RDF statements matching the given `pattern`.
  #
  # Monkey patch to RDF::Queryable#query to execute a {SPARQL::Algebra::Operator}
  # in addition to an {RDF::Query} object.
  #
  # @example
  #     queryable.query([nil, RDF::DOAP.developer, nil])
  #     queryable.query(:predicate => RDF::DOAP.developer)
  #
  #     op = SPARQL::Algebra::Expression.parse(%q((bgp (triple ?a doap:developer ?b))))
  #     queryable.query(op)
  #
  # @param  [RDF::Query, RDF::Statement, Array(RDF::Term), Hash, SPARQL::Operator] pattern
  # @yield  [statement]
  #   each matching statement
  # @yieldparam  [RDF::Statement] statement
  # @yieldreturn [void] ignored
  # @return [Enumerator]
  # @see    RDF::Queryable#query_pattern
  def query(pattern, &block)
    raise TypeError, "#{self} is not readable" if respond_to?(:readable?) && !readable?

    if pattern.is_a?(SPARQL::Algebra::Operator) && pattern.respond_to?(:execute)
      before_query(pattern) if respond_to?(:before_query)
      query_execute(pattern, &block)
      after_query(pattern) if respond_to?(:after_query)
      enum_for(:query_execute, pattern)
    else
      query_without_sparql(pattern, &block)
    end
  end
  
  ##
  # Concise Bounded Description
  #
  # Given a particular node (the starting node) in a particular RDF graph (the source graph), a subgraph of
  # that particular graph, taken to comprise a concise bounded description of the resource denoted by the
  # starting node, can be identified as follows:
  #
  #   1. Include in the subgraph all statements in the source graph where the subject of the statement is the
  #      starting node;
  #   2. Recursively, for all statements identified in the subgraph thus far having a blank node object,
  #      include in the subgraph all statements in the source graph where the subject of the statement is the
  #      blank node in question and which are not already included in the subgraph.
  #   3. Recursively, for all statements included in the subgraph thus far, for all reifications of each
  #      statement in the source graph, include the concise bounded description beginning from the
  #      rdf:Statement node of each reification. (we skip this step)
  #
  # This results in a subgraph where the object nodes are either URI references, literals, or blank nodes not
  # serving as the subject of any statement in the graph.
  #
  # Used to implement the SPARQL `describe` operator.
  #
  # @param [Array<RDF::Term>] *terms
  #   List of terms to include in the results.
  # @param [Hash{Symbol => Object}] options
  # @option options [Boolean] :non_subjects (true)
  #   If `term` is not a `subject` within `self`
  #   then add all `subject`s referencing the term as a `predicate` or `object`.
  # @option options [RDF::Graph] graph
  #   Graph containing statements already considered.
  # @yield [statement]
  # @yieldparam [RDF::Statement] statement
  # @yieldreturn [void] ignored
  # @return [RDF::Graph]
  #
  # @see http://www.w3.org/Submission/CBD/
  def concise_bounded_description(*terms, &block)
    options = terms.last.is_a?(Hash) ? terms.pop.dup : {}
    options[:non_subjects] = true unless options.has_key?(:non_subjects)

    graph = options[:graph] || RDF::Graph.new

    if options[:non_subjects]
      query_terms = terms.dup

      # Find terms not in self as a subject and recurse with their subjects
      terms.reject {|term| self.first(:subject => term)}.each do |term|
        self.query(:predicate => term) do |statement|
          query_terms << statement.subject
        end

        self.query(:object => term) do |statement|
          query_terms << statement.subject
        end
      end
      
      terms = query_terms.uniq
    end

    # Don't consider term if already in graph
    terms.reject {|term| graph.first(:subject => term)}.each do |term|
      # Find statements from queryiable with term as a subject
      self.query(:subject => term) do |statement|
        yield(statement) if block_given?
        graph << statement
        
        # Include reifications of this statement
        RDF::Query.new({
          :s => {
            RDF.type => RDF["Statement"],
            RDF.subject => statement.subject,
            RDF.predicate => statement.predicate,
            RDF.object => statement.object,
          }
        }).execute(self).each do |solution|
          # Recurse to include this subject
          recurse_opts = options.merge(:non_subjects => false, :graph => graph)
          self.concise_bounded_description(solution[:s], recurse_opts, &block)
        end

        # Recurse if object is a BNode and it is not already in subjects
        if statement.object.node?
          recurse_opts = options.merge(:non_subjects => false, :graph => graph)
          self.concise_bounded_description(statement.object, recurse_opts, &block)
        end
      end
    end
    
    graph
  end
end

class RDF::Query
  # Equivalence for Queries:
  #   Same Patterns
  #   Same Context
  # @return [Boolean]
  def ==(other)
    other.is_a?(RDF::Query) && patterns == other.patterns && context == context
  end

  # Transform Query into an Array form of an SSE
  #
  # If Query is named, it's treated as a GroupGraphPattern, otherwise, a BGP
  #
  # @return [Array]
  def to_sse
    res = [:bgp] + patterns.map(&:to_sse)
    (context ? [:graph, context, res] : res)
  end
end

class RDF::Query::Pattern
  # Transform Query Pattern into an SXP
  # @return [Array]
  def to_sse
    [:triple, subject, predicate, object]
  end
end

##
# Extensions for `RDF::Query::Variable`.
class RDF::Query::Variable
  include SPARQL::Algebra::Expression

  ##
  # Returns the value of this variable in the given `bindings`.
  #
  # @param  [RDF::Query::Solution, #[]] bindings
  # @return [RDF::Term] the value of this variable
  def evaluate(bindings = {})
    bindings[name.to_sym]
  end
end # RDF::Query::Variable

##
# Extensions for `RDF::Query::Solutions`.
class RDF::Query::Solutions
  alias_method :filter_without_expression, :filter

  ##
  # Filters this solution sequence by the given `criteria`.
  #
  # @param  [SPARQL::Algebra::Expression] expression
  # @yield  [solution]
  #   each solution
  # @yieldparam  [RDF::Query::Solution] solution
  # @yieldreturn [Boolean]
  # @return [void] `self`
  def filter(expression = {}, &block)
    case expression
      when SPARQL::Algebra::Expression
        filter_without_expression do |solution|
          expression.evaluate(solution).true?
        end
        filter_without_expression(&block) if block_given?
        self
      else filter_without_expression(expression, &block)
    end
  end
  alias_method :filter!, :filter
end # RDF::Query::Solutions

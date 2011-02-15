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
end

##
# Extensions for `RDF::Term`.
module RDF::Term
  include SPARQL::Algebra::Expression
end # RDF::Term

# Override RDF::Queryable to execute against SPARQL::Algebra::Query elements as well as RDF::Query and RDF::Pattern
module RDF::Queryable
  alias_method :query_without_sparql, :query
  ##
  # Queries `self` for RDF statements matching the given `pattern`.
  #
  # This method delegates to the protected {#query_pattern} method for the
  # actual lower-level query pattern matching implementation.
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
end

class RDF::Query
  # Transform Query into an Array form of an SSE
  #
  # If Query is named, it's treated as a GroupGraphPattern, otherwise, a BGP
  #
  # @return [Array]
  def to_sse
    res = [:bgp] + patterns.map(&:to_sse)
    (respond_to?(:named?) && named? ? [:graph, context, res] : res)
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

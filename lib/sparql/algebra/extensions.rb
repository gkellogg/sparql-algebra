##
# Extensions for `RDF::Term`.
module RDF::Term
  include SPARQL::Algebra::Expression
end # RDF::Term

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

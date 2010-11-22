##
# Extensions for `RDF::Term`.
module RDF::Term
  ##
  # Returns `self`.
  #
  # @param  [RDF::Query::Solution, #[]] bindings
  # @return [RDF::Term] `self`
  def evaluate(bindings = {})
    self
  end

  ##
  # Returns `self`.
  #
  # @return [RDF::Term] `self`
  def to_sse
    self
  end
end # RDF::Term

##
# Extensions for `RDF::Query::Variable`.
class RDF::Query::Variable
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

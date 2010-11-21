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

require 'rdf' # @see http://rubygems.org/gems/rdf

module SPARQL
  ##
  # A SPARQL algebra for RDF.rb.
  #
  # @see http://www.w3.org/TR/rdf-sparql-query/#sparqlAlgebra
  module Algebra
    autoload :Expression, 'sparql/algebra/expression'
    autoload :Operator,   'sparql/algebra/operator'
    autoload :VERSION,    'sparql/algebra/version'

    ##
    # @example
    #   Expression(:isLiteral, RDF::Literal(3.1415))
    #
    # @param  [Array] sse
    #   a SPARQL S-Expression (SSE) form
    # @return [Expression]
    def Expression(*sse)
      Expression.for(*sse)
    end
    alias_method :Expr, :Expression
    module_function :Expr, :Expression

    ##
    # @example
    #   Operator(:isLiteral)
    #
    # @param  [Symbol, #to_sym] name
    # @return [Class]
    def Operator(name, arity = nil)
      Operator.for(name, arity)
    end
    alias_method :Op, :Operator
    module_function :Op, :Operator

    ##
    # @example
    #   Variable(:foobar)
    #
    # @param  [Symbol, #to_sym] name
    # @return [Variable]
    # @see    http://rdf.rubyforge.org/RDF/Query/Variable.html
    def Variable(name)
      Variable.new(name)
    end
    alias_method :Var, :Variable
    module_function :Var, :Variable

    Variable = RDF::Query::Variable
  end # Algebra
end # SPARQL

require 'sparql/algebra/extensions'

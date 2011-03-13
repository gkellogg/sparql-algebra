require 'rdf' # @see http://rubygems.org/gems/rdf

module SPARQL
  ##
  # A SPARQL algebra for RDF.rb.
  #
  # Parses Sparql S-Expressions (SSE) into SPARQL Algebra operators.
  #
  # Operators implementing {SPARQL::Algebra::Query#execute} may directly
  # execute an object implementing {RDF::Queryable}, and so may be treated
  # equivalently to {RDF::Query}.
  #
  # Operators implementing {SPARQL::Algebra::Expression#evaluate} may be
  # evaluated with RDF::Query::Solution bindings to yield an appropriate result.
  #
  # An entire SSE expression is parsed into a recursive set of {SPARQL::Algebra::Operator}
  # instances, with each operand representing an additional operator.
  #
  # {RDF::Query} and {RDF::Query::Pattern} are used as primitives for `bgp` and `triple` expressions.
  #
  # @see http://www.w3.org/TR/rdf-sparql-query/#sparqlAlgebra
  module Algebra
    include RDF

    autoload :Evaluatable, 'sparql/algebra/evaluatable'
    autoload :Expression,  'sparql/algebra/expression'
    autoload :Operator,    'sparql/algebra/operator'
    autoload :Query,       'sparql/algebra/query'
    autoload :VERSION,     'sparql/algebra/version'

    ##
    # @example
    #   sse = (prefix ((foaf: <http://xmlns.com/foaf/0.1/>))
    #           (project (?name ?mbox)
    #             (join
    #               (bgp (triple ?x foaf:name ?name))
    #               (bgp (triple ?x foaf:mbox ?mbox)))))
    #   }
    # @param  [String] sse
    #   a SPARQL S-Expression (SSE) string
    # @param  [Hash{Symbol => Object}] options
    #   any additional options (see {Operator#initialize})
    # @return [SPARQL::Algebra::Operator]
    def parse(sse, options = {})
      Expression.parse(sse, options)
    end
    module_function :parse

    ##
    # @example
    #   Expression(:isLiteral, RDF::Literal(3.1415))
    #
    # @param  [Array] sse
    #   a SPARQL S-Expression (SSE) form
    # @return [SPARQL::Algebra::Expression]
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

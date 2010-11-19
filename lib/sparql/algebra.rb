require 'rdf' # @see http://rubygems.org/gems/rdf

module SPARQL
  ##
  # A SPARQL algebra for RDF.rb.
  #
  # @see http://www.w3.org/TR/rdf-sparql-query/#sparqlAlgebra
  module Algebra
    autoload :VERSION, 'sparql/algebra/version'
  end # Algebra
end # SPARQL

# coding: utf-8
#
require 'spec_helper'

# Auto-generated by build_w3c_tests.rb
#
# Cast to xsd:boolean
# 
# /Users/ben/repos/datagraph/tests/tests/data-r2/cast/cast-bool.rq
#
# This is a W3C test from the DAWG test suite:
# http://www.w3.org/2001/sw/DataAccess/tests/r2#cast-bool
#
# This test is approved: 
# http://lists.w3.org/Archives/Public/public-rdf-dawg/2007JulSep/att-0087/14-dawg-minutes.html
#
describe "W3C test" do
  context "cast" do
    before :all do
      @data = %q{
@prefix : <http://example.org/> .

:iri :p :z .
:str :p "string" .
:fltdbl :p "-10.2E3" .
:decimal :p "+33.3300" .
:int :p "13" .
:dT :p "2002-10-10T17:00:00Z" .
:bool :p "true" .

}
      @query = %q{
        (prefix ((xsd: <http://www.w3.org/2001/XMLSchema#>)
                 (rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>)
                 (: <http://example.org/>))
          (project (?s)
            (filter (= (datatype (xsd:boolean ?v)) xsd:boolean)
              (bgp (triple ?s :p ?v)))))
}
    end

    example "Cast to xsd:boolean" do
    
      graphs = {}
      graphs[:default] = { :data => @data, :format => :ttl}


      repository = 'cast-cast-bool'
      expected = [
          { 
              :s => RDF::URI('http://example.org/bool'),
          },
      ]

      pending("figuring out why xsd:boolean doesn't behave according to http://www.w3.org/TR/rdf-sparql-query/#FunctionMapping") do
        sparql_query(:graphs => graphs, :query => @query,       # unordered comparison in rspec is =~
                     :repository => repository, :form => :select).should =~ expected
     end
    end
  end
end
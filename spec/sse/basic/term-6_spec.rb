# coding: utf-8
#
require 'spec_helper'

# Auto-generated by build_w3c_tests.rb
#
# Basic - Term 6
# 
# /Users/ben/repos/datagraph/tests/tests/data-r2/basic/term-6.rq
#
# This is a W3C test from the DAWG test suite:
# http://www.w3.org/2001/sw/DataAccess/tests/r2#term-6
#
# This test is approved: 
# http://lists.w3.org/Archives/Public/public-rdf-dawg/2007JulSep/att-0060/2007-08-07-dawg-minutes.html
#
describe "W3C test" do
  context "basic" do
    before :all do
      @data = %q{
@prefix : <http://example.org/ns#> .
@prefix xsd:        <http://www.w3.org/2001/XMLSchema#> .
@prefix rdf:        <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .

:x :p1 "true"^^xsd:boolean .
:x :p2 "false"^^xsd:boolean .

:x rdf:type :C .

:x :n1  "123.0"^^xsd:decimal .
:x :n2  "456."^^xsd:decimal .

:x :n3 "+5"^^xsd:integer .
:x :n4 "-18"^^xsd:integer .

}
      @query = %q{
        (prefix ((: <http://example.org/ns#>)
                 (xsd: <http://www.w3.org/2001/XMLSchema#>))
          (bgp (triple :x ?p 456.)))
}
    end

    example "Basic - Term 6" do
    
      graphs = {}
      graphs[:default] = { :data => @data, :format => :ttl}


      repository = 'basic-term-6'
      expected = [
          { 
              :p => RDF::URI('http://example.org/ns#n2'),
          },
      ]


      sparql_query(:graphs => graphs, :query => @query,       # unordered comparison in rspec is =~
                   :repository => repository, :form => :select).should =~ expected
    end
  end
end

# coding: utf-8
#
require 'spec_helper'

# Auto-generated by build_w3c_tests.rb
#
# OPTIONAL - Inner FILTER with negative EBV for outer variables
# FILTER inside an OPTIONAL does not corrupt the entire solution
# /Users/ben/repos/datagraph/tests/tests/data-r2/optional-filter/expr-4.rq
#
# This is a W3C test from the DAWG test suite:
# http://www.w3.org/2001/sw/DataAccess/tests/r2#dawg-optional-filter-004
#
# This test is approved: 
# http://lists.w3.org/Archives/Public/public-rdf-dawg/2007OctDec/att-0006/02-dawg-minutes.html
#
# 20101218 jaa : bug : the solution field requires a place-holder for unbound variables
# 20101219 jaa : unbound marker now supported

describe "W3C test" do
  context "optional-filter" do
    before :all do
      @data = %q{
@prefix x: <http://example.org/ns#> .
@prefix : <http://example.org/books#> .
@prefix dc:         <http://purl.org/dc/elements/1.1/> .
@prefix xsd:        <http://www.w3.org/2001/XMLSchema#> .

:book1 dc:title "TITLE 1" .
:book1 x:price  "10"^^xsd:integer .

:book2 dc:title "TITLE 2" .
:book2 x:price  "20"^^xsd:integer .

:book3 dc:title "TITLE 3" .

}
      @query = %q{
        (prefix ((dc: <http://purl.org/dc/elements/1.1/>)
                 (x: <http://example.org/ns#>))
          (project (?title ?price)
            (leftjoin
              (bgp (triple ?book dc:title ?title))
              (bgp (triple ?book x:price ?price))
              (&& (< ?price 15) (= ?title "TITLE 2")))))
}
    end

    example "OPTIONAL - Inner FILTER with negative EBV for outer variables" do
    
      graphs = {}
      graphs[:default] = { :data => @data, :format => :ttl}


      repository = 'optional-filter-dawg-optional-filter-004'
      expected = [
          { 
              :title => RDF::Literal.new('TITLE 1' ),
          },
          { 
              :title => RDF::Literal.new('TITLE 3' ),
          },
          { 
              :title => RDF::Literal.new('TITLE 2' ),
          },
      ]


      sparql_query(:graphs => graphs, :query => @query,       # unordered comparison in rspec is =~
                   :repository => repository, :form => :select).should =~ expected
    end
  end
end

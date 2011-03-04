# coding: utf-8
#
require 'spec_helper'

# Auto-generated by build_w3c_tests.rb
#
# date-1
# Added type : xsd:date '='
# /Users/ben/repos/datagraph/tests/tests/data-r2/open-world/date-1.rq
#
# This is a W3C test from the DAWG test suite:
# http://www.w3.org/2001/sw/DataAccess/tests/r2#date-1
#
# This test is approved: 
# http://lists.w3.org/Archives/Public/public-rdf-dawg/2007AprJun/att-0082/2007-06-12-dawg-minutes.html
#
describe "W3C test" do
  context "open-world" do
    before :all do
      @data = %q{
@prefix     : <http://example/> .
@prefix  xsd:    <http://www.w3.org/2001/XMLSchema#> .

:dt1 :r "2006-08-23T09:00:00+01:00"^^xsd:dateTime .

:d1 :r "2006-08-23"^^xsd:date .
:d2 :r "2006-08-23Z"^^xsd:date .
:d3 :r "2006-08-23+00:00"^^xsd:date .

:d4 :r "2001-01-01"^^xsd:date .
:d5 :r "2001-01-01Z"^^xsd:date .

:d6 :s "2006-08-23"^^xsd:date .
:d7 :s "2006-08-24Z"^^xsd:date .
:d8 :s "2000-01-01"^^xsd:date .

}
      @query = %q{
        (prefix ((xsd: <http://www.w3.org/2001/XMLSchema#>)
                 (: <http://example/>))
          (filter (= ?v "2006-08-23"^^xsd:date)
            (bgp (triple ?x :r ?v))))
}
    end

    example "date-1" do
    
      graphs = {}
      graphs[:default] = { :data => @data, :format => :ttl}


      repository = 'open-world-date-2'
      expected = [
          { 
              :v => RDF::Literal.new('2006-08-23' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#date')),
              :x => RDF::URI('http://example/d1'),
          },
      ]

      pending("Not Approved, and RDF.rb does object matching, not lexical matching") do
        sparql_query(:graphs => graphs, :query => @query,       # unordered comparison in rspec is =~
                     :repository => repository, :form => :select).should =~ expected
      end
    end
  end
end
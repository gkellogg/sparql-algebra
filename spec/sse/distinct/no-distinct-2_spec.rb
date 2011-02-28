# coding: utf-8
#
require 'spec_helper'

# Auto-generated by build_w3c_tests.rb
#
# Strings: No distinct
# 
# /Users/ben/repos/datagraph/tests/tests/data-r2/distinct/no-distinct-1.rq
#
# This is a W3C test from the DAWG test suite:
# http://www.w3.org/2001/sw/DataAccess/tests/r2#no-distinct-2
#
# This test is approved: 
# http://www.w3.org/2007/07/17-dawg-minutes
#
describe "W3C test" do
  context "distinct" do
    before :all do
      @data = %q{
@prefix :         <http://example/> .
@prefix xsd:      <http://www.w3.org/2001/XMLSchema#> .

:x1 :p "abc" .
:x1 :q "abc" .

:x2 :p "abc"@en .
:x2 :q "abc"@en .

:x3 :p "ABC" .
:x3 :q "ABC" .

:x4 :p "ABC"@en .
:x4 :q "ABC"@en .


:x5 :p "abc"^^xsd:string .
:x5 :q "abc"^^xsd:string .
:x6 :p "ABC"^^xsd:string .
:x6 :q "ABC"^^xsd:string .

:x7 :p "" .
:x7 :q "" .

:x8 :p ""@en .
:x8 :q ""@en .

:x9 :p ""^^xsd:string .
:x9 :q ""^^xsd:string .

}
      @query = %q{
        (project (?v)
          (bgp (triple ?x ?p ?v)))
}
    end

    example "Strings: No distinct" do
    
      graphs = {}
      graphs[:default] = { :data => @data, :format => :ttl}


      repository = 'distinct-no-distinct-2'
      expected = [
          { 
              :v => RDF::Literal.new('ABC' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#string')),
          },
          { 
              :v => RDF::Literal.new('ABC' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#string')),
          },
          { 
              :v => RDF::Literal.new('abc' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#string')),
          },
          { 
              :v => RDF::Literal.new('abc' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#string')),
          },
          { 
              :v => RDF::Literal.new('ABC', :language => 'en' ),
          },
          { 
              :v => RDF::Literal.new('ABC', :language => 'en' ),
          },
          { 
              :v => RDF::Literal.new('ABC' ),
          },
          { 
              :v => RDF::Literal.new('ABC' ),
          },
          { 
              :v => RDF::Literal.new('' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#string')),
          },
          { 
              :v => RDF::Literal.new('' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#string')),
          },
          { 
              :v => RDF::Literal.new('abc', :language => 'en' ),
          },
          { 
              :v => RDF::Literal.new('abc', :language => 'en' ),
          },
          { 
              :v => RDF::Literal.new('', :language => 'en' ),
          },
          { 
              :v => RDF::Literal.new('', :language => 'en' ),
          },
          { 
              :v => RDF::Literal.new('abc' ),
          },
          { 
              :v => RDF::Literal.new('abc' ),
          },
          { 
              :v => RDF::Literal.new('' ),
          },
          { 
              :v => RDF::Literal.new('' ),
          },
      ]


      sparql_query(:graphs => graphs, :query => @query,       # unordered comparison in rspec is =~
                   :repository => repository, :form => :select).should =~ expected
    end
  end
end

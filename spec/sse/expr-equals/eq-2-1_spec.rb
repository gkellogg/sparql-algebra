# coding: utf-8
#
require 'spec_helper'

# Auto-generated by build_w3c_tests.rb
#
# Equality - 2 var - test equals
# = in FILTER is value equality
# /Users/ben/repos/datagraph/tests/tests/data-r2/expr-equals/query-eq2-1.rq
#
# This is a W3C test from the DAWG test suite:
# http://www.w3.org/2001/sw/DataAccess/tests/r2#eq-2-1
#
# This test is approved: 
# http://www.w3.org/2007/06/19-dawg-minutes.html
#
# 20101218 jaa : bug indicator : fails to match {:v1=>#<RDF::Literal:0x4be5b14("1")>, :v2=>#<RDF::Literal:0x4be5ab0("1")>} solution
# 20101219 jaa : bug indicator : = operator failure semantics are unclear

describe "W3C test" do
  context "expr-equals" do
    before :all do
      @data = %q{
@prefix    :        <http://example.org/things#> .
@prefix xsd:        <http://www.w3.org/2001/XMLSchema#> .

:xi1 :p  "1"^^xsd:integer .
:xi2 :p  "1"^^xsd:integer .
:xi3 :p  "01"^^xsd:integer .

:xd1 :p  "1.0e0"^^xsd:double .
:xd2 :p  "1.0"^^xsd:double .
:xd3 :p  "1"^^xsd:double .

## :xdec1 :p  "1.0"^^xsd:decimal .
## :xdec2 :p  "1"^^xsd:decimal .
## :xdec3 :p  "01"^^xsd:decimal .

:xt1 :p  "zzz"^^:myType .

:xp1 :p  "zzz" .
:xp2 :p  "1" .

:xu :p  :z .

#:xb :p  _:a .

}
      @query = %q{
        (prefix ((xsd: <http://www.w3.org/2001/XMLSchema#>)
                 (: <http://example.org/things#>))
          (project (?v1 ?v2)
            (filter (= ?v1 ?v2)
              (bgp
                (triple ?x1 :p ?v1)
                (triple ?x2 :p ?v2)
              ))))
}
    end

    example "Equality - 2 var - test equals", :status => 'bug' do
    
      graphs = {}
      graphs[:default] = { :data => @data, :format => :ttl}


      repository = 'expr-equals-eq-2-1'
      expected = [
          { 
              :v1 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
              :v2 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
          },
          { 
              :v1 => RDF::Literal.new('zzz' , :datatype => RDF::URI('http://example.org/things#myType')),
              :v2 => RDF::Literal.new('zzz' , :datatype => RDF::URI('http://example.org/things#myType')),
          },
          { 
              :v1 => RDF::Literal.new('1.0e0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
              :v2 => RDF::Literal.new('1.0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
          },
          { 
              :v1 => RDF::Literal.new('zzz' ),
              :v2 => RDF::Literal.new('zzz' ),
          },
          { 
              :v1 => RDF::Literal.new('1.0e0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
              :v2 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
          },
          { 
              :v1 => RDF::Literal.new('1.0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
              :v2 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
          },
          { 
              :v1 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
              :v2 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
          },
          { 
              :v1 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
              :v2 => RDF::Literal.new('1.0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
          },
          { 
              :v1 => RDF::Literal.new('01' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
              :v2 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
          },
          { 
              :v1 => RDF::Literal.new('1.0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
              :v2 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
          },
          { 
              :v1 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
              :v2 => RDF::Literal.new('01' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
          },
          { 
              :v1 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
              :v2 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
          },
          { 
              :v1 => RDF::Literal.new('1.0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
              :v2 => RDF::Literal.new('1.0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
          },
          { 
              :v1 => RDF::Literal.new('01' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
              :v2 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
          },
          { 
              :v1 => RDF::Literal.new('01' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
              :v2 => RDF::Literal.new('01' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
          },
          { 
              :v1 => RDF::Literal.new('01' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
              :v2 => RDF::Literal.new('1.0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
          },
          { 
              :v1 => RDF::Literal.new('1.0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
              :v2 => RDF::Literal.new('01' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
          },
          { 
              :v1 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
              :v2 => RDF::Literal.new('1.0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
          },
          { 
              :v1 => RDF::Literal.new('01' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
              :v2 => RDF::Literal.new('1.0e0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
          },
          { 
              :v1 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
              :v2 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
          },
          { 
              :v1 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
              :v2 => RDF::Literal.new('1.0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
          },
          { 
              :v1 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
              :v2 => RDF::Literal.new('01' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
          },
          { 
              :v1 => RDF::Literal.new('1' ),
              :v2 => RDF::Literal.new('1' ),
          },
          { 
              :v1 => RDF::Literal.new('1.0e0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
              :v2 => RDF::Literal.new('1.0e0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
          },
          { 
              :v1 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
              :v2 => RDF::Literal.new('1.0e0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
          },
          { 
              :v1 => RDF::Literal.new('01' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
              :v2 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
          },
          { 
              :v1 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
              :v2 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
          },
          { 
              :v1 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
              :v2 => RDF::Literal.new('01' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
          },
          { 
              :v1 => RDF::Literal.new('1.0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
              :v2 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
          },
          { 
              :v1 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
              :v2 => RDF::Literal.new('1.0e0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
          },
          { 
              :v1 => RDF::Literal.new('1.0e0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
              :v2 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
          },
          { 
              :v1 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
              :v2 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
          },
          { 
              :v1 => RDF::Literal.new('1.0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
              :v2 => RDF::Literal.new('1.0e0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
          },
          { 
              :v1 => RDF::URI('http://example.org/things#z'),
              :v2 => RDF::URI('http://example.org/things#z'),
          },
          { 
              :v1 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
              :v2 => RDF::Literal.new('1.0e0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
          },
          { 
              :v1 => RDF::Literal.new('1.0e0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
              :v2 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
          },
          { 
              :v1 => RDF::Literal.new('1.0e0' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
              :v2 => RDF::Literal.new('01' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
          },
          { 
              :v1 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
              :v2 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
          },
          { 
              :v1 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
              :v2 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
          },
          { 
              :v1 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
              :v2 => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#double')),
          },
      ]


      sparql_query(:graphs => graphs, :query => @query,       # unordered comparison in rspec is =~
                   :repository => repository, :form => :select).should =~ expected
    end
  end
end

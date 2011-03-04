# coding: utf-8
#
require 'spec_helper'

# Auto-generated by build_w3c_tests.rb
#
# Basic - Prefix/Base 2
# 
# /Users/ben/repos/datagraph/tests/tests/data-r2/basic/base-prefix-2.rq
#
# This is a W3C test from the DAWG test suite:
# http://www.w3.org/2001/sw/DataAccess/tests/r2#base-prefix-2
#
# This test is approved: 
# http://lists.w3.org/Archives/Public/public-rdf-dawg/2007JulSep/att-0060/2007-08-07-dawg-minutes.html
#
describe "W3C test" do
  context "basic" do
    before :all do
      @data = %q{
@prefix ns: <http://example.org/ns#> .
@prefix x:  <http://example.org/x/> .
@prefix z:  <http://example.org/x/#> .

x:x ns:p  "d:x ns:p" .
x:x x:p   "x:x x:p" .

z:x z:p   "z:x z:p" .

}
      @query = %q{
        (prefix ((: <http://example.org/x/#>))
          (bgp (triple :x ?p ?v)))}
    end

    example "Basic - Prefix/Base 2" do
    
      graphs = {}
      graphs[:default] = { :data => @data, :format => :ttl}


      repository = 'basic-base-prefix-2'
      expected = [
          { 
              :p => RDF::URI('http://example.org/x/#p'),
              :v => RDF::Literal.new('z:x z:p' ),
          },
      ]


      sparql_query(:graphs => graphs, :query => @query,       # unordered comparison in rspec is =~
                   :repository => repository, :form => :select).should =~ expected
    end
  end
end
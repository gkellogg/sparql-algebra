# coding: utf-8
#
require 'spec_helper'

# Auto-generated by build_w3c_tests.rb
#
# dawg-construct-optional
# Reification of the default graph
# /Users/ben/repos/datagraph/tests/tests/data-r2/construct/query-construct-optional.rq
#
# This is a W3C test from the DAWG test suite:
# http://www.w3.org/2001/sw/DataAccess/tests/r2#construct-5
#
# This test is approved: 
# http://lists.w3.org/Archives/Public/public-rdf-dawg/2007JulSep/att-0047/31-dawg-minutes
#
# 20101219 jaa : bug indicator : construct not yet supported by the front-end

describe "W3C test" do
  context "construct" do
    before :all do
      @data = %q{
        @prefix : <http://example/> .
        @prefix xsd:        <http://www.w3.org/2001/XMLSchema#> .

        :x :p :a .
        :x :p :b .
        :x :p :c .
        :x :p "1"^^xsd:integer .

        :a :q "2"^^xsd:integer .
        :a :r "2"^^xsd:integer .

        :b :q "2"^^xsd:integer .
      }

      @query = %q{
        (prefix ((: <http://example/>))
          (construct ((triple ?x :p2 ?v))
            (project (?x ?o ?v)
              (leftjoin
                (bgp (triple ?x :p ?o))
                (bgp (triple ?o :q ?v))))))
      }

      @result = %q{
        @prefix :        <http://example/> .
        @prefix xsd:        <http://www.w3.org/2001/XMLSchema#> .

        :x    :p2           "2"^^xsd:integer .
      }
    end

    example "dawg-construct-optional", :status => 'bug' do
    
      graphs = {}
      graphs[:default] = { :data => @data, :format => :ttl}
      graphs[:result] = { :data => @result, :format => :ttl}

      repository = 'construct-construct-5'

      sparql_query(:graphs => graphs, :query => @query,
                   :repository => repository, :form => :construct).should be_true
    end
  end
end
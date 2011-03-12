# coding: utf-8
#
require 'spec_helper'

# This is a W3C test from the DAWG test suite:
# http://www.w3.org/2001/sw/DataAccess/tests/data-r2/dataset/dawg-dataset-08
describe "W3C test" do
  context "dataset" do
    before :all do
      @query = %q{
        (prefix ((: <http://example/>))
          (dataset (<data-g1.ttl> (named <data-g2.ttl>))
            (join
              (bgp (triple ?s ?p ?o))
              (graph ?g
                (bgp (triple ?s ?q ?v))))))
      }
    end

    example "dawg-dataset-08" do
    
      graphs = {}

      repository = 'dawg-dataset-08'
      expected = [
          {
            :s => RDF::URI("http://example/x"),
            :p => RDF::URI("http://example/p"),
            :o => RDF::Literal(1),
            :q => RDF::URI("http://example/q"),
            :v => RDF::Literal(2),
            :g => RDF::URI("data-g2.ttl")
          },
      ]

      sparql_query(:graphs => graphs, :query => @query, :base_uri => File.expand_path(__FILE__),
                   :repository => repository, :form => :select).should =~ expected

    end
  end
end
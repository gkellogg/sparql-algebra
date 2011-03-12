# coding: utf-8
#
require 'spec_helper'

# This is a W3C test from the DAWG test suite:
# http://www.w3.org/2001/sw/DataAccess/tests/data-r2/dataset/dawg-dataset-07
describe "W3C test" do
  context "dataset" do
    before :all do
      @query = %q{
        (prefix ((: <http://example/>))
          (dataset (<data-g1.ttl> (named <data-g2.ttl>))
            (union
              (bgp (triple ?s ?p ?o))
              (graph ?g
                (bgp (triple ?s ?p ?o))))))
      }
    end

    example "dawg-dataset-07" do
    
      graph_uris = {
        :g1 => RDF::URI(File.join(File.expand_path(File.dirname(__FILE__)), "data-g1.ttl")),
        :g2 => RDF::URI(File.join(File.expand_path(File.dirname(__FILE__)), "data-g2.ttl")),
        :g3 => RDF::URI(File.join(File.expand_path(File.dirname(__FILE__)), "data-g3.ttl")),
        :g4 => RDF::URI(File.join(File.expand_path(File.dirname(__FILE__)), "data-g4.ttl")),
      }

      graphs = {}

      repository = 'dawg-dataset-07'
      expected = [
          {
            :s => RDF::URI("http://example/x"), :p => RDF::URI("http://example/q"), :o => RDF::Literal(2), :g => graph_uris[:g2]
          },
          {
            :s => RDF::URI("http://example/x"), :p => RDF::URI("http://example/p"), :o => RDF::Literal(1)
          },
          {
            :s => RDF::URI("http://example/a"), :p => RDF::URI("http://example/p"), :o => RDF::Literal(9)
          },
      ]

      sparql_query(:graphs => graphs, :query => @query, :base_uri => File.expand_path(__FILE__),
                   :repository => repository, :form => :select).should =~ expected

    end
  end
end

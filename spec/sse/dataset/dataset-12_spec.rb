# coding: utf-8
#
require 'spec_helper'

# This is a W3C test from the DAWG test suite:
# http://www.w3.org/2001/sw/DataAccess/tests/data-r2/dataset/dawg-dataset-12
describe "W3C test" do
  context "dataset" do
    before :all do
      @query = %q{
        (prefix ((: <http://example/>))
          (dataset (<data-g1.ttl> <data-g2.ttl> <data-g3.ttl> <data-g4.ttl>
                    (named <data-g1.ttl>) (named <data-g2.ttl>) (named <data-g3.ttl>) (named <data-g4.ttl>))
            (union
              (bgp (triple ?s ?p ?o))
              (graph ?g
                (bgp (triple ?s ?p ?o))))))
      }
    end

    example "dawg-dataset-12" do
    
      graph_uris = {
        :g1 => RDF::URI(File.join(File.expand_path(File.dirname(__FILE__)), "data-g1.ttl")),
        :g2 => RDF::URI(File.join(File.expand_path(File.dirname(__FILE__)), "data-g2.ttl")),
        :g3 => RDF::URI(File.join(File.expand_path(File.dirname(__FILE__)), "data-g3.ttl")),
        :g4 => RDF::URI(File.join(File.expand_path(File.dirname(__FILE__)), "data-g4.ttl")),
      }

      graphs = {}

      repository = 'dawg-dataset-12'
      expected = [
        {
          :s => RDF::URI("http://example/x"),
          :p => RDF::URI("http://example/q"),
          :o => RDF::Literal(2),
          :g => graph_uris[:g2]
        },
        {
          :s => RDF::URI("http://example/x"),
          :p => RDF::URI("http://example/p"),
          :o => RDF::Literal(1),
        },
        {
          :s => RDF::URI("http://example/x"),
          :p => RDF::URI("http://example/p"),
          :o => RDF::Literal(1),
          :g => graph_uris[:g1]
        },
        {
          :s => RDF::Node.new("g3a"),
          :p => RDF::URI("http://example/p"),
          :o => RDF::Literal(9),
          :g => graph_uris[:g3]
        },
        {
          :s => RDF::Node.new("x"),
          :p => RDF::URI("http://example/q"),
          :o => RDF::Literal(2),
        },
        {
          :s => RDF::Node.new("x"),
          :p => RDF::URI("http://example/p"),
          :o => RDF::Literal(1),
        },
        {
          :s => RDF::Node.new("g4x"),
          :p => RDF::URI("http://example/q"),
          :o => RDF::Literal(2),
          :g => graph_uris[:g4]
        },
        {
          :s => RDF::URI("http://example/x"),
          :p => RDF::URI("http://example/q"),
          :o => RDF::Literal(2),
        },
        {
          :s => RDF::URI("http://example/a"),
          :p => RDF::URI("http://example/p"),
          :o => RDF::Literal(9),
          :g => graph_uris[:g1]
        },
        {
          :s => RDF::Node.new("a"),
          :p => RDF::URI("http://example/p"),
          :o => RDF::Literal(9),
        },
        {
          :s => RDF::Node.new("g3x"),
          :p => RDF::URI("http://example/p"),
          :o => RDF::Literal(1),
          :g => graph_uris[:g3]
        },
        {
          :s => RDF::URI("http://example/a"),
          :p => RDF::URI("http://example/p"),
          :o => RDF::Literal(9),
        },
      ]

      sparql_query(:graphs => graphs, :query => @query, :base_uri => File.expand_path(__FILE__),
                   :repository => repository, :form => :select).should =~ expected

    end
  end
end

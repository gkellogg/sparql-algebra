$:.unshift "."
require File.join(File.dirname(__FILE__), 'spec_helper')
require 'sparql/spec'
require 'rdf/isomorphic'

describe SPARQL::Algebra do
  describe "w3c dawg SPARQL syntax tests" do
    SPARQL::Spec.load_sparql1_0_tests.group_by(&:manifest).each do |man, tests|
      describe man.to_s.split("/")[-2] do
        tests.each do |t|
          case t.type
          when MF.QueryEvaluationTest
            it "evaluates #{t.name}" do

              graphs = t.graphs
              query = t.action.sse_string
              expected = t.solutions

              result = sparql_query(:graphs => graphs, :query => query, :base_uri => t.action.query_file,
                                    :repository => "sparql-spec", :form => t.form, :to_hash => false)

              case t.form
              when :select
                result.should be_a(RDF::Query::Solutions)
                result.should describe_solutions(expected)
              when :create, :describe
                result.should be_a(RDF::Queryable)
                result.should describe_solutions(expected)
              when :ask
                result.should be_true
              end
            end
          else
            it "??? #{t.name}" do
              puts t.inspect
              fail "Unknown test type #{t.type}"
            end
          end
        end
      end
    end
  end
end
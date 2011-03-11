$:.unshift "."
require File.join(File.dirname(__FILE__), 'spec_helper')
require 'sparql/spec'
require 'sparql/client'

describe SPARQL::Algebra do
  describe "w3c dawg SPARQL syntax tests" do
    SPARQL::Spec.load_sparql1_0_tests.group_by(&:manifest).each do |man, tests|
      describe man.to_s.split("/")[-2] do
        tests.each do |t|
          case t.type
          when MF.QueryEvaluationTest
            it "evaluates #{t.name}" do
              graphs = {}
              data = t.action.test_data
              graphs[:default] = {:data => IO.read(data.path), :format => :ttl} if data
              t.action.graphData.each do |g|
                graphs[g] = {:data => IO.read(g.path), :format => :ttl}
              end

              query = t.action.sse_string
              
              expected = select_results_snippet(t) if t.result

              result = sparql_query(:graphs => graphs, :query => query,
                                    :repository => "sparql-spec", :form => t.form)
              result.should =~ expected
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

  def select_results_snippet(test)
    results = if File.extname(test.result.path) == '.srx'
      SPARQL::Client.parse_xml_bindings(File.read(test.result.path)).map { |result| result.to_hash }
    else
      expected_repository = RDF::Repository.new 
      Spira.add_repository!(:results, expected_repository)
      expected_repository.load(test.result.path)
      SPARQL::Spec::ResultBindings.each.first.solutions
    end
  end
end
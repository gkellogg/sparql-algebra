require File.join(File.dirname(__FILE__), 'spec_helper')

include SPARQL::Algebra

::RSpec::Matchers.define :have_result_set do |expected|
  match do |result|
    result.map(&:to_hash).to_set.should == expected.to_set
  end
end

describe SPARQL::Algebra::Query do
  EX = RDF::EX = RDF::Vocabulary.new('http://example.org/') unless const_defined?(:EX)

  context "shortcuts" do
    it "translates 'a' to rdf:type" do
      sse = SPARQL::Algebra.parse(%q((triple <a> a <b>)))
      sse.should be_a(RDF::Statement)
      sse.predicate.should == RDF.type
      sse.predicate.lexical.should == 'a'
    end
  end
  
  context "BGPs" do
    context "querying for a specific statement" do
      it "returns an empty solution sequence if the statement does not exist" do
        @graph = RDF::Graph.new do |graph|
          graph << [EX.x1, EX.p1, EX.x2]
        end

        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (bgp (triple ex:x1 ex:p2 ex:x2)))))
        query.execute(@graph).should be_empty
      end
    end

    context "querying for a literal" do
      it "should return a sequence with an existing literal" do
        graph = RDF::Graph.new do |graph|
          graph << [EX.x1, EX.p1, RDF::Literal::Decimal.new(123.0)]
        end

        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (bgp (triple ?s ex:p1 123.0)))))
        query.execute(graph).map(&:to_hash).should == [{:s => EX.x1}]
      end
    end

    context "triple pattern combinations" do
      before :each do
        # Normally we would not want all of this crap in the graph for each
        # test, but this gives us the nice benefit that each test implicitly
        # tests returning only the correct results and not random other ones.
        @graph = RDF::Graph.new do |graph|
          # simple patterns
          graph << [EX.x1, EX.p, 1]
          graph << [EX.x2, EX.p, 2]
          graph << [EX.x3, EX.p, 3]

          # pattern with same variable twice
          graph << [EX.x4, EX.psame, EX.x4]

          # pattern with variable across 2 patterns
          graph << [EX.x5, EX.p3, EX.x3]
          graph << [EX.x5, EX.p2, EX.x3]

          # pattern following a chain
          graph << [EX.x6, EX.pchain, EX.target]
          graph << [EX.target, EX.pchain2, EX.target2]
          graph << [EX.target2, EX.pchain3, EX.target3]
        end
      end

      it "?s p o" do
        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (bgp (triple ?s ex:p 1)))))
        query.execute(@graph).should have_result_set([{ :s => EX.x1 }])
      end

      it "s ?p o" do
        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (bgp (triple ex:x2 ?p 2)))))
        query.execute(@graph).should have_result_set [ { :p => EX.p } ]
      end

      it "s p ?o" do
        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (bgp (triple ex:x3 ex:p ?o)))))
        query.execute(@graph).should have_result_set [ { :o => RDF::Literal.new(3) } ]
      end

      it "?s p ?o" do
        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (bgp (triple ?s ex:p ?o)))))
        query.execute(@graph).should have_result_set [ { :s => EX.x1, :o => RDF::Literal.new(1) },
                                                       { :s => EX.x2, :o => RDF::Literal.new(2) },
                                                       { :s => EX.x3, :o => RDF::Literal.new(3) }]
      end

      it "?s ?p o" do
        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (bgp (triple ?s ?p 3)))))
        query.execute(@graph).should have_result_set [ { :s => EX.x3, :p => EX.p } ]
      end

      it "s ?p ?o" do
        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (bgp (triple ex:x1 ?p ?o)))))
        query.execute(@graph).should have_result_set [ { :p => EX.p, :o => RDF::Literal(1) } ]
      end

      it "?s p o / ?s p1 o1" do
        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (bgp (triple ?s ex:p3 ex:x3)
                 (triple ?s ex:p2 ex:x3)))))
        query.execute(@graph).should have_result_set [ { :s => EX.x5 } ]
      end

      it "?s1 p ?o1 / ?o1 p2 ?o2 / ?o2 p3 ?o3" do
        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (bgp (triple ?s ex:pchain ?o)
                 (triple ?o ex:pchain2 ?o2)
                 (triple ?o2 ex:pchain3 ?o3)))))
        query.execute(@graph).should have_result_set [ { :s => EX.x6, :o => EX.target, :o2 => EX.target2, :o3 => EX.target3 } ]
      end

      it "?same p ?same" do
        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (bgp (triple ?same ex:psame ?same)))))
        query.execute(@graph).should have_result_set [ { :same => EX.x4 } ]
      end

      it "(distinct ?s)" do
        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (distinct
              (project (?s)
                (bgp (triple ?s ?p ?o)))))))
        query.execute(@graph).should have_result_set [ { :s => EX.x1 },
                                                       { :s => EX.x2 },
                                                       { :s => EX.x3 },
                                                       { :s => EX.x4 },
                                                       { :s => EX.x5 },
                                                       { :s => EX.x6 },
                                                       { :s => EX.target },
                                                       { :s => EX.target2 }]
      end
      
      it "(filter (isLiteral ?o))" do
        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (filter (isLiteral ?o)
              (bgp (triple ?s ex:p ?o))))))
        query.execute(@graph).should have_result_set [ { :s => EX.x1, :o => RDF::Literal.new(1) },
                                                       { :s => EX.x2, :o => RDF::Literal.new(2) },
                                                       { :s => EX.x3, :o => RDF::Literal.new(3) }]
      end
      
      it "(filter (< ?o 3))" do
        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (filter (< ?o 3)
              (bgp (triple ?s ex:p ?o))))))
        query.execute(@graph).should have_result_set [ { :s => EX.x1, :o => RDF::Literal.new(1) },
                                                       { :s => EX.x2, :o => RDF::Literal.new(2) }]
      end
      
      it "(filter (exprlist (> ?o 1) (< ?o 3)))" do
        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (filter (exprlist (> ?o 1) (< ?o 3))
              (bgp (triple ?s ex:p ?o))))))
        query.execute(@graph).should have_result_set [ { :s => EX.x2, :o => RDF::Literal.new(2) }]
      end
      
      it "(order ?o)" do
        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (order (?o)
              (bgp (triple ?s ex:p ?o))))))
        query.execute(@graph).should have_result_set [ { :s => EX.x1, :o => RDF::Literal.new(1) },
                                                       { :s => EX.x2, :o => RDF::Literal.new(2) },
                                                       { :s => EX.x3, :o => RDF::Literal.new(3) }]
      end
      
      it "(project (?o) ?p ?o)" do
        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (project (?o)
              (bgp (triple ex:x1 ?p ?o))))))
        query.execute(@graph).should have_result_set [ { :o => RDF::Literal(1) } ]
      end
      
      it "(reduced ?s)" do
        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (reduced
              (project (?s)
                (bgp (triple ?s ?p ?o)))))))
        query.execute(@graph).should have_result_set [ { :s => EX.x1 },
                                                       { :s => EX.x2 },
                                                       { :s => EX.x3 },
                                                       { :s => EX.x4 },
                                                       { :s => EX.x5 },
                                                       { :s => EX.x6 },
                                                       { :s => EX.target },
                                                       { :s => EX.target2 }]
      end
      
      it "(slice _ 1)" do
        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (slice _ 1
              (project (?s)
                (bgp (triple ?s ?p ?o)))))))
        query.execute(@graph).should have_result_set [ { :s => EX.x1 }]
      end
      
      it "(slice 1 2)" do
        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (slice 1 2
              (project (?s)
                (bgp (triple ?s ?p ?o)))))))
        query.execute(@graph).should have_result_set [ { :s => EX.x2 }, { :s => EX.x3 }]
      end
      
      it "(slice 5 _)" do
        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (slice 5 _
              (project (?s)
                (bgp (triple ?s ?p ?o)))))))
        query.execute(@graph).should have_result_set [ { :s => EX.x5 },
                                                       { :s => EX.x6 },
                                                       { :s => EX.target },
                                                       { :s => EX.target2 } ]
      end
      
      # From sp2b benchmark, query 7 bgp 2
      it "?class3 p o / ?doc3 p2 ?class3 / ?doc3 p3 ?bag3 / ?bag3 ?member3 ?doc" do
        @graph << [EX.class1, EX.subclass, EX.document]
        @graph << [EX.class2, EX.subclass, EX.document]
        @graph << [EX.class3, EX.subclass, EX.other]

        @graph << [EX.doc1, EX.type, EX.class1]
        @graph << [EX.doc2, EX.type, EX.class1]
        @graph << [EX.doc3, EX.type, EX.class2]
        @graph << [EX.doc4, EX.type, EX.class2]
        @graph << [EX.doc5, EX.type, EX.class3]

        @graph << [EX.doc1, EX.refs, EX.bag1]
        @graph << [EX.doc2, EX.refs, EX.bag2]
        @graph << [EX.doc3, EX.refs, EX.bag3]
        @graph << [EX.doc5, EX.refs, EX.bag5]

        @graph << [EX.bag1, RDF::Node.new('ref1'), EX.doc11]
        @graph << [EX.bag1, RDF::Node.new('ref2'), EX.doc12]
        @graph << [EX.bag1, RDF::Node.new('ref3'), EX.doc13]

        @graph << [EX.bag2, RDF::Node.new('ref1'), EX.doc21]
        @graph << [EX.bag2, RDF::Node.new('ref2'), EX.doc22]
        @graph << [EX.bag2, RDF::Node.new('ref3'), EX.doc23]

        @graph << [EX.bag3, RDF::Node.new('ref1'), EX.doc31]
        @graph << [EX.bag3, RDF::Node.new('ref2'), EX.doc32]
        @graph << [EX.bag3, RDF::Node.new('ref3'), EX.doc33]

        @graph << [EX.bag5, RDF::Node.new('ref1'), EX.doc51]
        @graph << [EX.bag5, RDF::Node.new('ref2'), EX.doc52]
        @graph << [EX.bag5, RDF::Node.new('ref3'), EX.doc53]

        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (bgp (triple ?class3 ex:subclass ex:document)
                 (triple ?doc3 ex:type ?class3)
                 (triple ?doc3 ex:refs ?bag3)
                 (triple ?bag3 ?member3 ?doc)))))

        query.execute(@graph).map(&:to_hash).should =~ [
          { :doc3 => EX.doc1, :class3 => EX.class1, :bag3 => EX.bag1, :member3 => RDF::Node.new('ref1'), :doc => EX.doc11 },
          { :doc3 => EX.doc1, :class3 => EX.class1, :bag3 => EX.bag1, :member3 => RDF::Node.new('ref2'), :doc => EX.doc12 },
          { :doc3 => EX.doc1, :class3 => EX.class1, :bag3 => EX.bag1, :member3 => RDF::Node.new('ref3'), :doc => EX.doc13 },
          { :doc3 => EX.doc2, :class3 => EX.class1, :bag3 => EX.bag2, :member3 => RDF::Node.new('ref1'), :doc => EX.doc21 },
          { :doc3 => EX.doc2, :class3 => EX.class1, :bag3 => EX.bag2, :member3 => RDF::Node.new('ref2'), :doc => EX.doc22 },
          { :doc3 => EX.doc2, :class3 => EX.class1, :bag3 => EX.bag2, :member3 => RDF::Node.new('ref3'), :doc => EX.doc23 },
          { :doc3 => EX.doc3, :class3 => EX.class2, :bag3 => EX.bag3, :member3 => RDF::Node.new('ref1'), :doc => EX.doc31 },
          { :doc3 => EX.doc3, :class3 => EX.class2, :bag3 => EX.bag3, :member3 => RDF::Node.new('ref2'), :doc => EX.doc32 },
          { :doc3 => EX.doc3, :class3 => EX.class2, :bag3 => EX.bag3, :member3 => RDF::Node.new('ref3'), :doc => EX.doc33 }
        ]
      end

      # From sp2b benchmark, query 7 bgp 1
      it "?class subclass document / ?doc type ?class / ?doc title ?title / ?bag2 ?member2 ?doc / ?doc2 refs ?bag2" do
        @graph << [EX.class1, EX.subclass, EX.document]
        @graph << [EX.class2, EX.subclass, EX.document]
        @graph << [EX.class3, EX.subclass, EX.other]

        @graph << [EX.doc1, EX.type, EX.class1]
        @graph << [EX.doc2, EX.type, EX.class1]
        @graph << [EX.doc3, EX.type, EX.class2]
        @graph << [EX.doc4, EX.type, EX.class2]
        @graph << [EX.doc5, EX.type, EX.class3]
        # no doc6 type

        @graph << [EX.doc1, EX.title, EX.title1]
        @graph << [EX.doc2, EX.title, EX.title2]
        @graph << [EX.doc3, EX.title, EX.title3]
        @graph << [EX.doc4, EX.title, EX.title4]
        @graph << [EX.doc5, EX.title, EX.title5]
        @graph << [EX.doc6, EX.title, EX.title6]

        @graph << [EX.doc1, EX.refs, EX.bag1]
        @graph << [EX.doc2, EX.refs, EX.bag2]
        @graph << [EX.doc3, EX.refs, EX.bag3]
        @graph << [EX.doc5, EX.refs, EX.bag5]

        @graph << [EX.bag1, RDF::Node.new('ref1'), EX.doc11]
        @graph << [EX.bag1, RDF::Node.new('ref2'), EX.doc12]
        @graph << [EX.bag1, RDF::Node.new('ref3'), EX.doc13]

        @graph << [EX.bag2, RDF::Node.new('ref1'), EX.doc21]
        @graph << [EX.bag2, RDF::Node.new('ref2'), EX.doc22]
        @graph << [EX.bag2, RDF::Node.new('ref3'), EX.doc23]

        @graph << [EX.bag3, RDF::Node.new('ref1'), EX.doc31]
        @graph << [EX.bag3, RDF::Node.new('ref2'), EX.doc32]
        @graph << [EX.bag3, RDF::Node.new('ref3'), EX.doc33]

        @graph << [EX.bag5, RDF::Node.new('ref1'), EX.doc51]
        @graph << [EX.bag5, RDF::Node.new('ref2'), EX.doc52]
        @graph << [EX.bag5, RDF::Node.new('ref3'), EX.doc53]

        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (bgp (triple ?class ex:subclass ex:document)
                 (triple ?doc ex:type ?class)
                 (triple ?doc ex:title ?title)
                 (triple ?doc ex:refs ?bag)
                 (triple ?bag ?member ?doc2)))))

        query.execute(@graph).map(&:to_hash).should =~ [
          { :doc => EX.doc1, :class => EX.class1, :bag => EX.bag1,
            :member => RDF::Node.new('ref1'), :doc2 => EX.doc11, :title => EX.title1 },
          { :doc => EX.doc1, :class => EX.class1, :bag => EX.bag1,
            :member => RDF::Node.new('ref2'), :doc2 => EX.doc12, :title => EX.title1 },
          { :doc => EX.doc1, :class => EX.class1, :bag => EX.bag1,
            :member => RDF::Node.new('ref3'), :doc2 => EX.doc13, :title => EX.title1 },
          { :doc => EX.doc2, :class => EX.class1, :bag => EX.bag2,
            :member => RDF::Node.new('ref1'), :doc2 => EX.doc21, :title => EX.title2 },
          { :doc => EX.doc2, :class => EX.class1, :bag => EX.bag2,
            :member => RDF::Node.new('ref2'), :doc2 => EX.doc22, :title => EX.title2 },
          { :doc => EX.doc2, :class => EX.class1, :bag => EX.bag2,
            :member => RDF::Node.new('ref3'), :doc2 => EX.doc23, :title => EX.title2 },
          { :doc => EX.doc3, :class => EX.class2, :bag => EX.bag3,
            :member => RDF::Node.new('ref1'), :doc2 => EX.doc31, :title => EX.title3 },
          { :doc => EX.doc3, :class => EX.class2, :bag => EX.bag3,
            :member => RDF::Node.new('ref2'), :doc2 => EX.doc32, :title => EX.title3 },
          { :doc => EX.doc3, :class => EX.class2, :bag => EX.bag3,
            :member => RDF::Node.new('ref3'), :doc2 => EX.doc33, :title => EX.title3 },
        ]
      end

      it "?s1 p ?o1 / ?s2 p ?o2" do
        graph = RDF::Graph.new do |graph|
          graph << [EX.x1, EX.p, 1]
          graph << [EX.x2, EX.p, 2]
        end
        query = SPARQL::Algebra::Expression.parse(%q(
          (prefix ((ex: <http://example.org/>))
            (bgp (triple ?s1 ex:p ?o1)
                 (triple ?s2 ex:p ?o2)))))
        # Use set comparison for unordered compare on 1.8.7
        query.execute(graph).map(&:to_hash).to_set.should == [
          {:s1 => EX.x1, :o1 => RDF::Literal(1), :s2 => EX.x1, :o2 => RDF::Literal(1)},
          {:s1 => EX.x1, :o1 => RDF::Literal(1), :s2 => EX.x2, :o2 => RDF::Literal(2)},
          {:s1 => EX.x2, :o1 => RDF::Literal(2), :s2 => EX.x1, :o2 => RDF::Literal(1)},
          {:s1 => EX.x2, :o1 => RDF::Literal(2), :s2 => EX.x2, :o2 => RDF::Literal(2)},
        ].to_set
      end
    end
  end

  context "join" do
    it "passes data/extracted-examples/query-4.1" do
      sparql_query(
        :graphs => {
          :default => {
            :data => %q{
              @prefix foaf:       <http://xmlns.com/foaf/0.1/> .
              @prefix rdf:        <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .

              _:a  rdf:type        foaf:Person .
              _:a  foaf:name       "Alice" .
              _:a  foaf:mbox       <mailto:alice@example.com> .
              _:a  foaf:mbox       <mailto:alice@work.example> .

              _:b  rdf:type        foaf:Person .
              _:b  foaf:name       "Bob" .
            },
            :format => :ttl
          }
        },
        :query => %q{
          (prefix ((foaf: <http://xmlns.com/foaf/0.1/>))
            (project (?name ?mbox)
              (join
                (bgp (triple ?x foaf:name ?name))
                (bgp (triple ?x foaf:mbox ?mbox)))))
        }
      ).map(&:to_hash).should == [
        {:name => RDF::Literal.new("Alice"), :mbox => RDF::URI("mailto:alice@example.com")},
        {:name => RDF::Literal.new("Alice"), :mbox => RDF::URI("mailto:alice@work.example")},
      ]
    end
    
    it "parses " do
      query = %q((graph ?g
          (join
            (bgp (triple :x :b ?a))
            (graph ?g2
              (bgp (triple :x :p ?x))))))
      
      SPARQL::Algebra.parse(query).should be_a(SPARQL::Algebra::Operator::Join)
    end
  end
  
  context "leftjoin" do
    it "passes data/examples/ex11.2.3.2_1" do
      sparql_query(
        :graphs => {
          :default => {
            :data => %q{
              @prefix foaf:        <http://xmlns.com/foaf/0.1/> .
              @prefix dc:          <http://purl.org/dc/elements/1.1/> .
              @prefix xs:          <http://www.w3.org/2001/XMLSchema#> .

              _:a  foaf:name       "Alice".

              _:b  foaf:givenName  "Bob" .
              _:b  dc:created      "2005-04-04T04:04:04Z"^^xs:dateTime .
            },
            :format => :ttl
          }
        },
        :query => %q{
          (prefix ((dc: <http://purl.org/dc/elements/1.1/>)
                   (foaf: <http://xmlns.com/foaf/0.1/>))
            (project (?name)
              (filter (! (bound ?created))
                (leftjoin
                  (bgp (triple ?x foaf:name ?name))
                  (bgp (triple ?x dc:created ?created))))))
        }
      ).map(&:to_hash).should == [
        {:name => RDF::Literal.new("Alice")},
      ]
    end

    it "passes data-r2/algebra/op-filter-1" do
      sparql_query(
        :graphs => {
          :default => {
            :data => %q{
              @prefix   :         <http://example/> .
              @prefix xsd:        <http://www.w3.org/2001/XMLSchema#> .

              :x1 :p "1"^^xsd:integer .
              :x2 :p "2"^^xsd:integer .

              :x3 :q "3"^^xsd:integer .
              :x3 :q "4"^^xsd:integer .
            },
            :format => :ttl
          }
        },
        :query => %q{
          (prefix ((: <http://example/>))
            (leftjoin
              (bgp (triple ?x :p ?v))
              (bgp (triple ?y :q ?w))
              (= ?v 2)))
        }
      ).map(&:to_hash).should =~ [
        { 
            :v => RDF::Literal.new('2' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
            :w => RDF::Literal.new('4' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
            :x => RDF::URI('http://example/x2'),
            :y => RDF::URI('http://example/x3'),
        },
        { 
            :v => RDF::Literal.new('2' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
            :w => RDF::Literal.new('3' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
            :x => RDF::URI('http://example/x2'),
            :y => RDF::URI('http://example/x3'),
        },
        { 
            :v => RDF::Literal.new('1' , :datatype => RDF::URI('http://www.w3.org/2001/XMLSchema#integer')),
            :x => RDF::URI('http://example/x1'),
        },
      ]
    end
  end
  
  context "union" do
    it "passes data/extracted-examples/query-6.1" do
      sparql_query(
        :graphs => {
          :default => {
            :data => %q{
              @prefix dc10:  <http://purl.org/dc/elements/1.0/> .
              @prefix dc11:  <http://purl.org/dc/elements/1.1/> .

              _:a  dc10:title     "SPARQL Query Language Tutorial" .

              _:b  dc11:title     "SPARQL Protocol Tutorial" .

              _:c  dc10:title     "SPARQL" .
              _:c  dc11:title     "SPARQL (updated)" .
            },
            :format => :ttl
          }
        },
        :query => %q{
          (prefix ((dc11: <http://purl.org/dc/elements/1.1/>)
                   (dc10: <http://purl.org/dc/elements/1.0/>))
            (project (?title)
              (union
                (bgp (triple ?book dc10:title ?title))
                (bgp (triple ?book dc11:title ?title)))))
        }
      ).map(&:to_hash).should =~ [
        {:title => RDF::Literal.new("SPARQL Query Language Tutorial")},
        {:title => RDF::Literal.new("SPARQL Protocol Tutorial")},
        {:title => RDF::Literal.new("SPARQL")},
        {:title => RDF::Literal.new("SPARQL (updated)")},
      ]
    end
  end

  context "ask" do
    it "passes data-r2/as/ask-1" do
      sparql_query(
        :form => :ask,
        :graphs => {
          :default => {
            :data => %q{
              @prefix :   <http://example/> .
              @prefix xsd:        <http://www.w3.org/2001/XMLSchema#> .

              :x :p "1"^^xsd:integer .
              :x :p "2"^^xsd:integer .
              :x :p "3"^^xsd:integer .

              :y :p :a .
              :a :q :r .
            },
            :format => :ttl
          }
        },
        :query => %q{
          (prefix ((: <http://example/>))
          (ask
            (bgp (triple :x :p 1))))
        }
      ).should be_true
    end
  end

  context "describe" do
    {
      :uri => [
        %q{
          <http://example/subject> a <http://example/type> .
          <http://example/subject2> a <http://example/anothertype> .
        },
        %q{
          <http://example/subject> a <http://example/type> .
        },
        %q{
          (describe (<http://example/subject>) (bgp))
        },
      ],
      :foaf => [
        %q{
          @prefix foaf:   <http://xmlns.com/foaf/0.1/> .
          @prefix vcard:  <http://www.w3.org/2001/vcard-rdf/3.0> .
          @prefix exOrg:  <http://org.example.com/employees#> .
          @prefix rdf:    <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
          @prefix owl:    <http://www.w3.org/2002/07/owl#> .

          _:a     exOrg:employeeId    "1234" ;
                  foaf:mbox_sha1sum   "ABCD1234" ;
                  vcard:N
                   [ vcard:Family       "Smith" ;
                     vcard:Given        "John"  ] .

          foaf:mbox_sha1sum  rdf:type  owl:InverseFunctionalProperty .
        },
        %q{
          @prefix foaf:   <http://xmlns.com/foaf/0.1/> .
          @prefix vcard:  <http://www.w3.org/2001/vcard-rdf/3.0> .
          @prefix exOrg:  <http://org.example.com/employees#> .
          @prefix rdf:    <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
          @prefix owl:    <http://www.w3.org/2002/07/owl#> .

          _:a     exOrg:employeeId    "1234" ;
                  foaf:mbox_sha1sum   "ABCD1234" ;
                  vcard:N
                   [ vcard:Family       "Smith" ;
                     vcard:Given        "John"  ] .
        },
        %q{
          (prefix ((exOrg: <http://org.example.com/employees#>))
            (describe (?x)
              (bgp (triple ?x exOrg:employeeId "1234"))))
        }
      ]
    }.each do |example, (source, result, query)|
      it "describes #{example}" do
        graph_r = RDF::Graph.new << RDF::N3::Reader.new(result)

        sparql_query(
          :form => :describe,
          :graphs => {:default => {:data => source, :format => :ttl}},
          :query => query).should == graph_r
      end
    end
  end

  context "query forms" do
    {
      # @see http://www.w3.org/TR/rdf-sparql-query/#QSynIRI
      %q((base <http://example.org/>
          (bgp (triple <a> <b> 123.0)))) =>
        Operator::Base.new(
          RDF::URI("http://example.org/"),
          RDF::Query.new {pattern [RDF::URI("http://example.org/a"), RDF::URI("http://example.org/b"), RDF::Literal.new(123.0)]}),

      # @see http://www.w3.org/TR/rdf-sparql-query/#modDistinct
      %q((distinct
          (bgp (triple <a> <b> 123.0)))) =>
        Operator::Distinct.new(
          RDF::Query.new {pattern [RDF::URI("a"), RDF::URI("b"), RDF::Literal.new(123.0)]}),

      # @see http://www.w3.org/TR/rdf-sparql-query/#evaluation
      %q((exprlist (< ?x 1))) =>
        Operator::Exprlist.new(
          Operator::LessThan.new(Variable("x"), RDF::Literal.new(1))),
      %q((exprlist (< ?x 1) (> ?y 1))) =>
        Operator::Exprlist.new(
          Operator::LessThan.new(Variable("x"), RDF::Literal.new(1)),
          Operator::GreaterThan.new(Variable("y"), RDF::Literal.new(1))),

      # @see http://www.w3.org/TR/rdf-sparql-query/#evaluation
      %q((filter
          (< ?x 1)
          (bgp (triple <a> <b> 123.0)))) =>
        Operator::Filter.new(
          Operator::LessThan.new(Variable("x"), RDF::Literal.new(1)),
          RDF::Query.new {pattern [RDF::URI("a"), RDF::URI("b"), RDF::Literal.new(123.0)]}),

      %q((filter
          (exprlist
            (< ?x 1)
            (> ?y 1))
          (bgp (triple <a> <b> 123.0)))) =>
        Operator::Filter.new(
          Operator::Exprlist.new(
            Operator::LessThan.new(Variable("x"), RDF::Literal.new(1)),
            Operator::GreaterThan.new(Variable("y"), RDF::Literal.new(1))),
          RDF::Query.new {pattern [RDF::URI("a"), RDF::URI("b"), RDF::Literal.new(123.0)]}),

      # @see http://www.w3.org/TR/rdf-sparql-query/#ebv
      %q((filter ?x
          (bgp (triple <a> <b> 123.0)))) =>
        Operator::Filter.new(
          Variable("x"),
          RDF::Query.new {pattern [RDF::URI("a"), RDF::URI("b"), RDF::Literal.new(123.0)]}),
      %q((filter
          (= ?x <a>)
          (bgp (triple <a> <b> 123.0)))) =>
        Operator::Filter.new(
          Operator::Equal.new(Variable("x"), RDF::URI("a")),
          RDF::Query.new {pattern [RDF::URI("a"), RDF::URI("b"), RDF::Literal.new(123.0)]}),

      # @see http://www.w3.org/TR/rdf-sparql-query/#namedAndDefaultGraph
      %q((graph ?g
          (bgp  (triple <a> <b> 123.0)))) =>
        Operator::Graph.new(
          Variable("g"),
          RDF::Query.new {pattern [RDF::URI("a"), RDF::URI("b"), RDF::Literal.new(123.0)]}),

      # @see http://www.w3.org/TR/rdf-sparql-query/#sparqlAlgebra
      %q((join
          (bgp (triple <a> <b> 123.0))
          (bgp (triple <a> <b> 456.0)))) =>
        Operator::Join.new(
          RDF::Query.new {pattern [RDF::URI("a"), RDF::URI("b"), RDF::Literal.new(123.0)]},
          RDF::Query.new {pattern [RDF::URI("a"), RDF::URI("b"), RDF::Literal.new(456.0)]}),

      # @see http://www.w3.org/TR/rdf-sparql-query/#sparqlAlgebra
      %q((leftjoin
          (bgp (triple <a> <b> 123.0))
          (bgp (triple <a> <b> 456.0)))) =>
        Operator::LeftJoin.new(
          RDF::Query.new {pattern [RDF::URI("a"), RDF::URI("b"), RDF::Literal.new(123.0)]},
          RDF::Query.new {pattern [RDF::URI("a"), RDF::URI("b"), RDF::Literal.new(456.0)]}),
      %q((leftjoin
          (bgp (triple <a> <b> 123.0))
          (bgp (triple <a> <b> 456.0))
          (bound ?x))) =>
        Operator::LeftJoin.new(
          RDF::Query.new {pattern [RDF::URI("a"), RDF::URI("b"), RDF::Literal.new(123.0)]},
          RDF::Query.new {pattern [RDF::URI("a"), RDF::URI("b"), RDF::Literal.new(456.0)]},
          Operator::Bound.new(Variable("x"))),

      # @see http://www.w3.org/TR/rdf-sparql-query/#modOrderBy
      %q((order (<a>)
          (bgp (triple <a> <b> ?o)))) =>
        Operator::Order.new(
          [RDF::URI("a")],
          RDF::Query.new {pattern [RDF::URI("a"), RDF::URI("b"), Variable("o")]}),
      %q((order (<a> <b>)
          (bgp (triple <a> <b> ?o)))) =>
        Operator::Order.new(
          [RDF::URI("a"), RDF::URI("b")],
          RDF::Query.new {pattern [RDF::URI("a"), RDF::URI("b"), Variable("o")]}),
      %q((order ((asc 1))
          (bgp (triple <a> <b> ?o)))) =>
        Operator::Order.new(
          [Operator::Asc.new(RDF::Literal.new(1))],
          RDF::Query.new {pattern [RDF::URI("a"), RDF::URI("b"), Variable("o")]}),
      %q((order ((desc ?a))
          (bgp (triple <a> <b> ?a)))) =>
        Operator::Order.new(
          [Operator::Desc.new(Variable("a"))],
          RDF::Query.new {pattern [RDF::URI("a"), RDF::URI("b"), Variable("a")]}),
      %q((order (?a ?b ?c)
          (bgp (triple <a> <b> ?o)))) =>
        Operator::Order.new(
          [Variable(?a), Variable(?b), Variable(?c)],
          RDF::Query.new {pattern [RDF::URI("a"), RDF::URI("b"), Variable("o")]}),
      %q((order (?a (asc 1) (isIRI <b>))
          (bgp (triple <a> <b> ?o)))) =>
        Operator::Order.new(
          [Variable(?a), Operator::Asc.new(RDF::Literal.new(1)), Operator::IsIRI.new(RDF::URI("b"))],
          RDF::Query.new {pattern [RDF::URI("a"), RDF::URI("b"), Variable("o")]}),

      # @see http://www.w3.org/TR/rdf-sparql-query/#QSynIRI
      %q((prefix ((ex: <http://example.org/>))
          (bgp (triple ?s ex:p1 123.0)))) =>
        Operator::Prefix.new(
          [[:"ex:", RDF::URI("http://example.org/")]],
          RDF::Query.new {pattern [RDF::Query::Variable.new("s"), EX.p1, RDF::Literal.new(123.0)]}),

      # @see http://www.w3.org/TR/rdf-sparql-query/#modProjection
      %q((project (?s)
          (bgp (triple ?s <p> 123.0)))) =>
        Operator::Project.new(
          [Variable("s")],
          RDF::Query.new {pattern [Variable("s"), RDF::URI("p"), RDF::Literal.new(123.0)]}),

      # @see http://www.w3.org/TR/rdf-sparql-query/#modReduced
      %q((reduced
          (bgp (triple <a> <b> 123.0)))) =>
        Operator::Reduced.new(
          RDF::Query.new {pattern [RDF::URI("a"), RDF::URI("b"), RDF::Literal.new(123.0)]}),

      # @see http://www.w3.org/TR/rdf-sparql-query/#sparqlAlgebraEval
      %q((slice _ 100
          (bgp (triple <a> <b> 123.0)))) =>
        Operator::Slice.new(
          :_, RDF::Literal.new(100),
          RDF::Query.new {pattern [RDF::URI("a"), RDF::URI("b"), RDF::Literal.new(123.0)]}),
      %q((slice 1 2
          (bgp (triple <a> <b> 123.0)))) =>
        Operator::Slice.new(
          RDF::Literal.new(1), RDF::Literal.new(2),
          RDF::Query.new {pattern [RDF::URI("a"), RDF::URI("b"), RDF::Literal.new(123.0)]}),


      # @see http://www.w3.org/TR/rdf-sparql-query/#sparqlTriplePatterns
      %q((triple <a> <b> <c>)) => RDF::Query::Pattern.new(RDF::URI("a"), RDF::URI("b"), RDF::URI("c")),
      %q((triple ?a _:b "c")) => RDF::Query::Pattern.new(RDF::Query::Variable.new("a"), RDF::Node.new("b"), RDF::Literal.new("c")),

      # @see http://www.w3.org/TR/rdf-sparql-query/#sparqlBasicGraphPatterns
      %q((bgp (triple <a> <b> <c>))) => RDF::Query.new { pattern [RDF::URI("a"), RDF::URI("b"), RDF::URI("c")]},

      # @see http://www.w3.org/TR/rdf-sparql-query/#sparqlAlgebra
      %q((union
          (bgp (triple <a> <b> 123.0))
          (bgp (triple <a> <b> 456.0)))) =>
        Operator::Union.new(
          RDF::Query.new {pattern [RDF::URI("a"), RDF::URI("b"), RDF::Literal.new(123.0)]},
          RDF::Query.new {pattern [RDF::URI("a"), RDF::URI("b"), RDF::Literal.new(456.0)]}),
    }.each_pair do |sse, operator|
      it "generates SSE for #{sse}" do
        SXP::Reader::SPARQL.read(sse).should == operator.to_sse
      end
    
      it "parses SSE for #{sse}" do
        SPARQL::Algebra::Expression.parse(sse).should == operator
      end
    end
  end
end

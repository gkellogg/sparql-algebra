require File.join(File.dirname(__FILE__), 'spec_helper')

describe SPARQL::Algebra::Operator do
  before :all do
    @is_blank   = SPARQL::Algebra::Operator::IsBlank.new
    @is_iri     = SPARQL::Algebra::Operator::IsIRI.new
    @is_literal = SPARQL::Algebra::Operator::IsLiteral.new
    @str        = SPARQL::Algebra::Operator::Str.new
  end

  context "IsBlank" do
    describe "#evaluate(RDF::Node)" do
      it "returns true" do
        @is_blank.evaluate(RDF::Node.new).should eql RDF::Literal(true)
      end
    end

    describe "#evaluate(RDF::URI)" do
      it "returns false" do
        @is_blank.evaluate(RDF::URI('http://rdf.rubyforge.org/')).should eql RDF::Literal(false)
      end
    end
  end

  context "IsIRI" do
    describe "#evaluate(RDF::URI)" do
      it "returns true" do
        @is_iri.evaluate(RDF::URI('http://rdf.rubyforge.org/')).should eql RDF::Literal(true)
      end
    end

    describe "#evaluate(RDF::Node)" do
      it "returns false" do
        @is_iri.evaluate(RDF::Node.new).should eql RDF::Literal(false)
      end
    end
  end

  context "IsLiteral" do
    describe "#evaluate(RDF::Literal)" do
      it "returns true" do
        @is_literal.evaluate(RDF::Literal("Hello")).should eql RDF::Literal(true)
      end
    end

    describe "#evaluate(RDF::Node)" do
      it "returns false" do
        @is_literal.evaluate(RDF::Node.new).should eql RDF::Literal(false)
      end
    end

    describe "#evaluate(RDF::URI)" do
      it "returns false" do
        @is_literal.evaluate(RDF::DC.title).should eql RDF::Literal(false)
      end
    end
  end

  context "Str" do
    describe "#evaluate(RDF::Literal)" do
      it "returns the lexical value as a plain literal" do
        @str.evaluate(RDF::Literal("Hello")).should eql RDF::Literal("Hello")
        @str.evaluate(RDF::Literal(3.1415)).should eql RDF::Literal("3.1415")
      end
    end

    describe "#evaluate(RDF::URI)" do
      it "returns the IRI string as a plain literal" do
        @str.evaluate(RDF::DC.title).should eql RDF::Literal(RDF::DC.title.to_s)
      end
    end
  end
end

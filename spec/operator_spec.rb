require File.join(File.dirname(__FILE__), 'spec_helper')

describe SPARQL::Algebra::Operator do
  before :all do
    @is_iri     = SPARQL::Algebra::Operator::IsIRI.new
    @is_blank   = SPARQL::Algebra::Operator::IsBlank.new
    @is_literal = SPARQL::Algebra::Operator::IsLiteral.new
  end

  describe "IsIRI#evaluate(RDF::Node)" do
    it "returns false" do
      @is_iri.evaluate(RDF::Node.new).should eql RDF::Literal(false)
    end
  end

  describe "IsIRI#evaluate(RDF::URI)" do
    it "returns true" do
      @is_iri.evaluate(RDF::URI('http://rdf.rubyforge.org/')).should eql RDF::Literal(true)
    end
  end

  describe "IsBlank#evaluate(RDF::Node)" do
    it "returns true" do
      @is_blank.evaluate(RDF::Node.new).should eql RDF::Literal(true)
    end
  end

  describe "IsBlank#evaluate(RDF::URI)" do
    it "returns false" do
      @is_blank.evaluate(RDF::URI('http://rdf.rubyforge.org/')).should eql RDF::Literal(false)
    end
  end

  describe "IsLiteral#evaluate(RDF::Node)" do
    it "returns false" do
      @is_literal.evaluate(RDF::Node.new).should eql RDF::Literal(false)
    end
  end

  describe "IsLiteral#evaluate(RDF::URI)" do
    it "returns false" do
      @is_literal.evaluate(RDF::DC.title).should eql RDF::Literal(false)
    end
  end

  describe "IsLiteral#evaluate(RDF::Literal)" do
    it "returns true" do
      @is_literal.evaluate(RDF::Literal("Hello")).should eql RDF::Literal(true)
    end
  end
end

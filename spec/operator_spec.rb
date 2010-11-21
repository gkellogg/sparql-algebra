require File.join(File.dirname(__FILE__), 'spec_helper')

describe SPARQL::Algebra do
  # @see http://www.w3.org/TR/rdf-sparql-query/#OperatorMapping
  before :all do
    @op         = SPARQL::Algebra::Operator
    @not        = SPARQL::Algebra::Operator::Not
    @plus       = SPARQL::Algebra::Operator::Plus
    @minus      = SPARQL::Algebra::Operator::Minus
    @bound      = SPARQL::Algebra::Operator::Bound
    @is_iri     = SPARQL::Algebra::Operator::IsIRI
    @is_blank   = SPARQL::Algebra::Operator::IsBlank
    @is_literal = SPARQL::Algebra::Operator::IsLiteral
    @str        = SPARQL::Algebra::Operator::Str
    @lang       = SPARQL::Algebra::Operator::Lang
    @datatype   = SPARQL::Algebra::Operator::Datatype
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#ebv
  context "Operator" do
    describe "#boolean(true)" do
      it "returns RDF::Literal(true)" do
        @op.new.send(:boolean, true).should eql RDF::Literal(true)
      end
    end

    describe "#boolean(false)" do
      it "returns RDF::Literal(false)" do
        @op.new.send(:boolean, false).should eql RDF::Literal(false)
      end
    end

    describe "#boolean(RDF::Literal::Boolean)" do
      it "returns RDF::Literal(false) if the operand's lexical form is not valid" do
        @op.new.send(:boolean, RDF::Literal::Boolean.new('t')).should eql RDF::Literal(false)
        @op.new.send(:boolean, RDF::Literal::Boolean.new('f')).should eql RDF::Literal(false)
      end
    end

    describe "#boolean(RDF::Literal::TRUE)" do
      it "returns RDF::Literal(true)" do
        @op.new.send(:boolean, RDF::Literal(true)).should eql RDF::Literal(true)
      end
    end

    describe "#boolean(RDF::Literal::FALSE)" do
      it "returns RDF::Literal(false)" do
        @op.new.send(:boolean, RDF::Literal(false)).should eql RDF::Literal(false)
      end
    end

    describe "#boolean(RDF::Literal::Numeric)" do
      it "returns RDF::Literal(false) if the operand's lexical form is not valid" do
        @op.new.send(:boolean, RDF::Literal::Integer.new('abc')).should eql RDF::Literal(false)
      end

      it "returns RDF::Literal(false) if the operand is NaN" do
        @op.new.send(:boolean, RDF::Literal(0/0.0)).should eql RDF::Literal(false)
      end

      it "returns RDF::Literal(false) if the operand is numerically equal to zero" do
        @op.new.send(:boolean, RDF::Literal(0)).should eql RDF::Literal(false)
        @op.new.send(:boolean, RDF::Literal(0.0)).should eql RDF::Literal(false)
      end

      it "returns RDF::Literal(true) otherwise" do
        @op.new.send(:boolean, RDF::Literal(42)).should eql RDF::Literal(true)
      end
    end

    describe "#boolean(RDF::Literal) with a plain literal" do
      it "returns RDF::Literal(false) if the operand has zero length" do
        @op.new.send(:boolean, RDF::Literal("")).should eql RDF::Literal(false)
      end

      it "returns RDF::Literal(true) otherwise" do
        @op.new.send(:boolean, RDF::Literal("Hello")).should eql RDF::Literal(true)
      end
    end

    describe "#boolean(RDF::Literal) with a typed literal of datatype xsd:string" do
      it "returns RDF::Literal(false) if the operand has zero length" do
        @op.new.send(:boolean, RDF::Literal("", :datatype => RDF::XSD.string)).should eql RDF::Literal(false)
      end

      it "returns RDF::Literal(true) otherwise" do
        @op.new.send(:boolean, RDF::Literal("Hello", :datatype => RDF::XSD.string)).should eql RDF::Literal(true)
      end
    end

    describe "#boolean(RDF::Literal) with a language-tagged literal" do
      it "raises a TypeError" do
        lambda { @op.new.send(:boolean, RDF::Literal("Hello", :language => :en)) }.should raise_error TypeError
      end
    end

    describe "#boolean(RDF::Term)" do
      it "raises a TypeError" do
        lambda { @op.new.send(:boolean, RDF::Node.new) }.should raise_error TypeError
        lambda { @op.new.send(:boolean, RDF::DC.title) }.should raise_error TypeError
      end
    end
  end

  # @see http://www.w3.org/TR/xpath-functions/#func-not
  context "Operator::Not" do
    describe ".evaluate(RDF::Literal(true))" do
      it "returns RDF::Literal(false)" do
        @not.evaluate(RDF::Literal(true)).should eql RDF::Literal(false)
      end
    end

    describe ".evaluate(RDF::Literal(false))" do
      it "returns RDF::Literal(true)" do
        @not.evaluate(RDF::Literal(false)).should eql RDF::Literal(true)
      end
    end

    describe ".evaluate(term)" do
      it "returns an RDF::Literal::Boolean" do
        pending # TODO
      end
    end

    describe "#to_sse" do
      it "returns the correct SSE form" do
        @not.new(RDF::Literal(true)).to_sse.should == [:not, RDF::Literal(true)]
      end
    end
  end

  # @see http://www.w3.org/TR/xpath-functions/#func-numeric-unary-plus
  context "Operator::Plus" do
    describe ".evaluate(RDF::Literal::Numeric)" do
      it "returns the operand incremented by one" do
        @plus.evaluate(RDF::Literal(41)).should eql RDF::Literal(42)
      end
    end

    describe ".evaluate(RDF::Literal)" do
      it "raises a TypeError" do
        lambda { @plus.evaluate(RDF::Literal('')) }.should raise_error TypeError
      end
    end

    describe "#to_sse" do
      it "returns the correct SSE form" do
        @plus.new(RDF::Literal(42)).to_sse.should == [:+, RDF::Literal(42)]
      end
    end
  end

  # @see http://www.w3.org/TR/xpath-functions/#func-numeric-unary-minus
  context "Operator::Minus" do
    describe ".evaluate(RDF::Literal::Numeric)" do
      it "returns the operand decremented by one" do
        @minus.evaluate(RDF::Literal(43)).should eql RDF::Literal(42)
      end
    end

    describe ".evaluate(RDF::Literal)" do
      it "raises a TypeError" do
        lambda { @minus.evaluate(RDF::Literal('')) }.should raise_error TypeError
      end
    end

    describe "#to_sse" do
      it "returns the correct SSE form" do
        @minus.new(RDF::Literal(42)).to_sse.should == [:-, RDF::Literal(42)]
      end
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#func-bound
  context "Operator::Bound" do
    describe ".evaluate(RDF::Query::Variable)" do
      it "returns an RDF::Literal::Boolean" do
        @bound.evaluate(RDF::Query::Variable.new(:foo)).should be_an(RDF::Literal::Boolean)
      end
    end

    describe ".evaluate(term)" do
      it "raises a TypeError" do
        lambda { @bound.evaluate(nil) }.should raise_error TypeError
      end
    end

    describe "#to_sse" do
      it "returns the correct SSE form" do
        @bound.new(RDF::Query::Variable.new(:foo)).to_sse.should == [:bound, RDF::Query::Variable.new(:foo)]
      end
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#func-isIRI
  context "Operator::IsIRI" do
    describe ".evaluate(RDF::URI)" do
      it "returns RDF::Literal(true)" do
        @is_iri.evaluate(RDF::URI('http://rdf.rubyforge.org/')).should eql RDF::Literal(true)
      end
    end

    describe ".evaluate(RDF::Node)" do
      it "returns RDF::Literal(false)" do
        @is_iri.evaluate(RDF::Node.new).should eql RDF::Literal(false)
      end
    end

    describe ".evaluate(RDF::Literal)" do
      it "returns RDF::Literal(false)" do
        @is_iri.evaluate(RDF::Literal(42)).should eql RDF::Literal(false)
      end
    end

    describe "#to_sse" do
      it "returns the correct SSE form" do
        @is_iri.new(RDF::DC.title).to_sse.should == [:isIRI, RDF::DC.title]
      end
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#func-isBlank
  context "Operator::IsBlank" do
    describe ".evaluate(RDF::Node)" do
      it "returns RDF::Literal(true)" do
        @is_blank.evaluate(RDF::Node.new).should eql RDF::Literal(true)
      end
    end

    describe ".evaluate(RDF::URI)" do
      it "returns RDF::Literal(false)" do
        @is_blank.evaluate(RDF::URI('http://rdf.rubyforge.org/')).should eql RDF::Literal(false)
      end
    end

    describe ".evaluate(RDF::Literal)" do
      it "returns RDF::Literal(false)" do
        @is_blank.evaluate(RDF::Literal(42)).should eql RDF::Literal(false)
      end
    end

    describe "#to_sse" do
      it "returns the correct SSE form" do
        @is_blank.new(RDF::Node.new(:foo)).to_sse.should == [:isBlank, RDF::Node.new(:foo)]
      end
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#func-isLiteral
  context "Operator::IsLiteral" do
    describe ".evaluate(RDF::Literal)" do
      it "returns RDF::Literal(true)" do
        @is_literal.evaluate(RDF::Literal("Hello")).should eql RDF::Literal(true)
      end
    end

    describe ".evaluate(RDF::Node)" do
      it "returns RDF::Literal(false)" do
        @is_literal.evaluate(RDF::Node.new).should eql RDF::Literal(false)
      end
    end

    describe ".evaluate(RDF::URI)" do
      it "returns RDF::Literal(false)" do
        @is_literal.evaluate(RDF::DC.title).should eql RDF::Literal(false)
      end
    end

    describe "#to_sse" do
      it "returns the correct SSE form" do
        @is_literal.new(RDF::Literal("Hello")).to_sse.should == [:isLiteral, RDF::Literal("Hello")]
      end
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#func-str
  context "Operator::Str" do
    describe ".evaluate(RDF::Literal)" do
      it "returns the lexical value as a simple literal" do
        @str.evaluate(RDF::Literal("Hello")).should eql RDF::Literal("Hello")
        @str.evaluate(RDF::Literal(3.1415)).should eql RDF::Literal("3.1415")
      end
    end

    describe ".evaluate(RDF::URI)" do
      it "returns the IRI string as a simple literal" do
        @str.evaluate(RDF::DC.title).should eql RDF::Literal(RDF::DC.title.to_s)
      end
    end

    describe "#to_sse" do
      it "returns the correct SSE form" do
        @str.new(RDF::DC.title).to_sse.should == [:str, RDF::DC.title]
      end
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#func-lang
  context "Operator::Lang" do
    describe ".evaluate(RDF::Literal) with a simple literal" do
      it "returns an empty string as a simple literal" do
        @lang.evaluate(RDF::Literal('Hello')).should eql RDF::Literal('')
      end
    end

    describe ".evaluate(RDF::Literal) with a language-tagged literal" do
      it "returns the language tag as a simple literal" do
        @lang.evaluate(RDF::Literal('Hello', :language => :en)).should eql RDF::Literal('en')
        @lang.evaluate(RDF::Literal('Hello', :language => :EN)).should eql RDF::Literal('EN')
      end
    end

    describe ".evaluate(RDF::Term)" do
      it "raises a TypeError" do
        lambda { @lang.evaluate(RDF::Node.new) }.should raise_error TypeError
        lambda { @lang.evaluate(RDF::DC.title) }.should raise_error TypeError
      end
    end

    describe "#to_sse" do
      it "returns the correct SSE form" do
        @lang.new(RDF::Literal('Hello')).to_sse.should == [:lang, RDF::Literal('Hello')]
        @lang.new(RDF::Literal('Hello', :language => :en)).to_sse.should == [:lang, RDF::Literal('Hello', :language => :en)]
      end
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#func-datatype
  context "Operator::Datatype" do
    describe ".evaluate(RDF::Literal) with a simple literal" do
      it "returns the datatype IRI of xsd:string" do
        @datatype.evaluate(RDF::Literal('Hello')).should eql RDF::XSD.string
      end
    end

    describe ".evaluate(RDF::Literal) with a typed literal" do
      it "returns the datatype IRI" do
        @datatype.evaluate(RDF::Literal('Hello', :datatype => RDF::XSD.string)).should eql RDF::XSD.string
        @datatype.evaluate(RDF::Literal('Hello', :datatype => RDF::XSD.token)).should eql RDF::XSD.token
      end
    end

    describe ".evaluate(RDF::Literal) with a language-tagged literal" do
      it "raises a TypeError" do
        lambda { @datatype.evaluate(RDF::Literal('Hello', :language => :en)) }.should raise_error TypeError
      end
    end

    describe ".evaluate(RDF::Term)" do
      it "raises a TypeError" do
        lambda { @datatype.evaluate(RDF::Node.new) }.should raise_error TypeError
        lambda { @datatype.evaluate(RDF::DC.title) }.should raise_error TypeError
      end
    end

    describe "#to_sse" do
      it "returns the correct SSE form" do
        @datatype.new(RDF::Literal('Hello')).to_sse.should == [:datatype, RDF::Literal('Hello')]
        @datatype.new(RDF::Literal('Hello', :datatype => RDF::XSD.string)).to_sse.should == [:datatype, RDF::Literal('Hello', :datatype => RDF::XSD.string)]
      end
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#func-logical-or
  context "Operator::LogicalOr" do
    describe ".evaluate(a, b)" do
      # TODO
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#func-logical-and
  context "Operator::LogicalAnd" do
    describe ".evaluate(a, b)" do
      # TODO
    end
  end

  # @see http://www.w3.org/TR/xpath-functions/#func-numeric-equal
  # @see http://www.w3.org/TR/xpath-functions/#func-boolean-equal
  # @see http://www.w3.org/TR/xpath-functions/#func-dateTime-equal
  context "Operator::Equal" do
    describe ".evaluate(a, b)" do
      # TODO
    end
  end

  # @see http://www.w3.org/TR/xpath-functions/#func-numeric-equal
  # @see http://www.w3.org/TR/xpath-functions/#func-boolean-equal
  # @see http://www.w3.org/TR/xpath-functions/#func-dateTime-equal
  context "Operator::NotEqual" do
    describe ".evaluate(a, b)" do
      # TODO
    end
  end

  # @see http://www.w3.org/TR/xpath-functions/#func-numeric-less-than
  # @see http://www.w3.org/TR/xpath-functions/#func-boolean-less-than
  # @see http://www.w3.org/TR/xpath-functions/#func-dateTime-less-than
  context "Operator::LessThan" do
    describe ".evaluate(a, b)" do
      # TODO
    end
  end

  # @see http://www.w3.org/TR/xpath-functions/#func-numeric-less-than
  # @see http://www.w3.org/TR/xpath-functions/#func-boolean-less-than
  # @see http://www.w3.org/TR/xpath-functions/#func-dateTime-less-than
  context "Operator::GreaterThan" do
    describe ".evaluate(a, b)" do
      # TODO
    end
  end

  # @see http://www.w3.org/TR/xpath-functions/#func-numeric-less-than
  # @see http://www.w3.org/TR/xpath-functions/#func-boolean-less-than
  # @see http://www.w3.org/TR/xpath-functions/#func-dateTime-less-than
  context "Operator::LessThanOrEqual" do
    describe ".evaluate(a, b)" do
      # TODO
    end
  end

  # @see http://www.w3.org/TR/xpath-functions/#func-numeric-less-than
  # @see http://www.w3.org/TR/xpath-functions/#func-boolean-less-than
  # @see http://www.w3.org/TR/xpath-functions/#func-dateTime-less-than
  context "Operator::GreaterThanOrEqual" do
    describe ".evaluate(a, b)" do
      # TODO
    end
  end

  # @see http://www.w3.org/TR/xpath-functions/#func-numeric-multiply
  context "Operator::Multiply" do
    describe ".evaluate(a, b)" do
      # TODO
    end
  end

  # @see http://www.w3.org/TR/xpath-functions/#func-numeric-divide
  context "Operator::Divide" do
    describe ".evaluate(a, b)" do
      # TODO
    end
  end

  # @see http://www.w3.org/TR/xpath-functions/#func-numeric-add
  context "Operator::Add" do
    describe ".evaluate(a, b)" do
      # TODO
    end
  end

  # @see http://www.w3.org/TR/xpath-functions/#func-numeric-subtract
  context "Operator::Subtract" do
    describe ".evaluate(a, b)" do
      # TODO
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#func-RDFterm-equal
  context "Operator::Equal" do
    describe ".evaluate(RDF::Term, RDF::Term)" do
      it "returns RDF::Literal(true) if the terms are equal" do
        pending # TODO
      end

      it "returns RDF::Literal(false) if the terms are not equal" do
        pending # TODO
      end
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#func-RDFterm-equal
  context "Operator::NotEqual" do
    describe ".evaluate(RDF::Term, RDF::Term)" do
      it "returns RDF::Literal(false) if the terms are equal" do
        pending # TODO
      end

      it "returns RDF::Literal(true) if the terms are not equal" do
        pending # TODO
      end
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#func-sameTerm
  context "Operator::SameTerm" do
    describe ".evaluate(RDF::Term, RDF::Term)" do
      it "returns RDF::Literal(true) if the terms are the same" do
        pending # TODO
      end

      it "returns RDF::Literal(false) if the terms are not the same" do
        pending # TODO
      end
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#func-langMatches
  context "Operator::LangMatches" do
    describe ".evaluate(language_tag, language_range)" do
      # TODO
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#rRegexExpression
  # @see http://www.w3.org/TR/xpath-functions/#func-matches
  context "Operator::Regex" do
    describe ".evaluate(string, pattern)" do
      # TODO
    end

    describe ".evaluate(string, pattern, flags)" do
      # TODO
    end
  end
end

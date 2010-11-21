require File.join(File.dirname(__FILE__), 'spec_helper')

describe SPARQL::Algebra do
  # @see http://www.w3.org/TR/rdf-sparql-query/#OperatorMapping
  before :all do
    @op         = SPARQL::Algebra::Operator
    @op0        = SPARQL::Algebra::Operator::Nullary
    @op1        = SPARQL::Algebra::Operator::Unary
    @op2        = SPARQL::Algebra::Operator::Binary
    @op3        = SPARQL::Algebra::Operator::Ternary
    # Unary operators:
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
    # TODO: Binary operators
    @or         = SPARQL::Algebra::Operator::Or
    @and        = SPARQL::Algebra::Operator::And
    @same_term  = SPARQL::Algebra::Operator::SameTerm
    # TODO: Ternary operators
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#ebv
  context "Operator" do
    describe "#operands" do
      it "returns an Array" do
        @op0.new.operands.should be_an Array
      end
    end

    describe "#operand" do
      # TODO
    end

    describe "#variable?" do
      it "returns true if any of the operands are variables" do
        @op1.new(RDF::Query::Variable.new(:foo)).should be_variable
      end

      it "returns false if none of the operands are variables" do
        @op1.new(RDF::Node.new).should_not be_variable
      end
    end

    describe "#constant?" do
      it "returns true if none of the operands are variables" do
        @op1.new(RDF::Node.new).should be_constant
      end

      it "returns false if any of the operands are variables" do
        @op1.new(RDF::Query::Variable.new(:foo)).should_not be_constant
      end
    end

    describe "#evaluate" do
      it "raises a NotImplementedError" do
        lambda { @op.new.evaluate(nil) }.should raise_error NotImplementedError
      end
    end

    describe "#boolean(true)" do
      it "returns RDF::Literal::TRUE" do
        @op.new.send(:boolean, true).should eql RDF::Literal::TRUE
      end
    end

    describe "#boolean(false)" do
      it "returns RDF::Literal::FALSE" do
        @op.new.send(:boolean, false).should eql RDF::Literal::FALSE
      end
    end

    describe "#boolean(RDF::Literal::Boolean)" do
      it "returns RDF::Literal::FALSE if the operand's lexical form is not valid" do
        @op.new.send(:boolean, RDF::Literal::Boolean.new('t')).should eql RDF::Literal::FALSE
        @op.new.send(:boolean, RDF::Literal::Boolean.new('f')).should eql RDF::Literal::FALSE
      end
    end

    describe "#boolean(RDF::Literal::TRUE)" do
      it "returns RDF::Literal::TRUE" do
        @op.new.send(:boolean, RDF::Literal::TRUE).should eql RDF::Literal::TRUE
      end
    end

    describe "#boolean(RDF::Literal::FALSE)" do
      it "returns RDF::Literal::FALSE" do
        @op.new.send(:boolean, RDF::Literal::FALSE).should eql RDF::Literal::FALSE
      end
    end

    describe "#boolean(RDF::Literal::Numeric)" do
      it "returns RDF::Literal::FALSE if the operand's lexical form is not valid" do
        @op.new.send(:boolean, RDF::Literal::Integer.new('abc')).should eql RDF::Literal::FALSE
      end

      it "returns RDF::Literal::FALSE if the operand is NaN" do
        @op.new.send(:boolean, RDF::Literal(0/0.0)).should eql RDF::Literal::FALSE
      end

      it "returns RDF::Literal::FALSE if the operand is numerically equal to zero" do
        @op.new.send(:boolean, RDF::Literal(0)).should eql RDF::Literal::FALSE
        @op.new.send(:boolean, RDF::Literal(0.0)).should eql RDF::Literal::FALSE
      end

      it "returns RDF::Literal::TRUE otherwise" do
        @op.new.send(:boolean, RDF::Literal(42)).should eql RDF::Literal::TRUE
      end
    end

    describe "#boolean(RDF::Literal) with a plain literal" do
      it "returns RDF::Literal::FALSE if the operand has zero length" do
        @op.new.send(:boolean, RDF::Literal("")).should eql RDF::Literal::FALSE
      end

      it "returns RDF::Literal::TRUE otherwise" do
        @op.new.send(:boolean, RDF::Literal("Hello")).should eql RDF::Literal::TRUE
      end
    end

    describe "#boolean(RDF::Literal) with a typed literal of datatype xsd:string" do
      it "returns RDF::Literal::FALSE if the operand has zero length" do
        @op.new.send(:boolean, RDF::Literal("", :datatype => RDF::XSD.string)).should eql RDF::Literal::FALSE
      end

      it "returns RDF::Literal::TRUE otherwise" do
        @op.new.send(:boolean, RDF::Literal("Hello", :datatype => RDF::XSD.string)).should eql RDF::Literal::TRUE
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

  context "Operator::Nullary" do
    # TODO
  end

  context "Operator::Unary" do
    # TODO
  end

  context "Operator::Binary" do
    # TODO
  end

  context "Operator::Ternary" do
    # TODO
  end

  ##########################################################################
  # UNARY OPERATORS

  # @see http://www.w3.org/TR/xpath-functions/#func-not
  context "Operator::Not" do
    describe ".evaluate(RDF::Literal::TRUE)" do
      it "returns RDF::Literal::FALSE" do
        @not.evaluate(RDF::Literal::TRUE).should eql RDF::Literal::FALSE
      end
    end

    describe ".evaluate(RDF::Literal::FALSE)" do
      it "returns RDF::Literal::TRUE" do
        @not.evaluate(RDF::Literal::FALSE).should eql RDF::Literal::TRUE
      end
    end

    describe ".evaluate(RDF::Term)" do
      it "returns the inverse of the operand's effective boolean value (EBV)" do
        @not.evaluate(RDF::Literal(0/0.0)).should eql RDF::Literal::TRUE
        @not.evaluate(RDF::Literal(0)).should eql RDF::Literal::TRUE
        @not.evaluate(RDF::Literal(0.0)).should eql RDF::Literal::TRUE
        @not.evaluate(RDF::Literal("")).should eql RDF::Literal::TRUE
        @not.evaluate(RDF::Literal(""), :datatype => RDF::XSD.string).should eql RDF::Literal::TRUE
        @not.evaluate(RDF::Literal(42)).should eql RDF::Literal::FALSE
        @not.evaluate(RDF::Literal(3.1415)).should eql RDF::Literal::FALSE
        @not.evaluate(RDF::Literal("Hello")).should eql RDF::Literal::FALSE
        @not.evaluate(RDF::Literal("Hello"), :datatype => RDF::XSD.string).should eql RDF::Literal::FALSE
      end
    end

    describe "#to_sse" do
      it "returns the correct SSE form" do
        @not.new(RDF::Literal::TRUE).to_sse.should == [:not, RDF::Literal::TRUE]
      end
    end
  end

  # @see http://www.w3.org/TR/xpath-functions/#func-numeric-unary-plus
  context "Operator::Plus" do
    describe ".evaluate(RDF::Literal::Numeric)" do
      it "returns the operand incremented by one" do
        @plus.evaluate(RDF::Literal(41)).should eql RDF::Literal(42)
        @plus.evaluate(RDF::Literal(41.0)).should eql RDF::Literal(42.0)
        @plus.evaluate(RDF::Literal(BigDecimal('41.0'))).should eql RDF::Literal(BigDecimal('42.0'))
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
        @minus.evaluate(RDF::Literal(43.0)).should eql RDF::Literal(42.0)
        @minus.evaluate(RDF::Literal(BigDecimal('43.0'))).should eql RDF::Literal(BigDecimal('42.0'))
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

    # TODO: tests with actual solution sequences.

    describe ".evaluate(RDF::Term)" do
      it "raises a TypeError" do
        lambda { @bound.evaluate(nil) }.should raise_error TypeError
        lambda { @bound.evaluate(RDF::Node.new) }.should raise_error TypeError
        lambda { @bound.evaluate(RDF::DC.title) }.should raise_error TypeError
        lambda { @bound.evaluate(RDF::Literal::TRUE) }.should raise_error TypeError
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
      it "returns RDF::Literal::TRUE" do
        @is_iri.evaluate(RDF::URI('http://rdf.rubyforge.org/')).should eql RDF::Literal::TRUE
      end
    end

    describe ".evaluate(RDF::Term)" do
      it "returns RDF::Literal::FALSE" do
        @is_iri.evaluate(RDF::Node.new).should eql RDF::Literal::FALSE
        @is_iri.evaluate(RDF::Literal(42)).should eql RDF::Literal::FALSE
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
      it "returns RDF::Literal::TRUE" do
        @is_blank.evaluate(RDF::Node.new).should eql RDF::Literal::TRUE
      end
    end

    describe ".evaluate(RDF::Term)" do
      it "returns RDF::Literal::FALSE" do
        @is_blank.evaluate(RDF::URI('http://rdf.rubyforge.org/')).should eql RDF::Literal::FALSE
        @is_blank.evaluate(RDF::Literal(42)).should eql RDF::Literal::FALSE
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
      it "returns RDF::Literal::TRUE" do
        @is_literal.evaluate(RDF::Literal("Hello")).should eql RDF::Literal::TRUE
      end
    end

    describe ".evaluate(RDF::Term)" do
      it "returns RDF::Literal::FALSE" do
        @is_literal.evaluate(RDF::Node.new).should eql RDF::Literal::FALSE
        @is_literal.evaluate(RDF::DC.title).should eql RDF::Literal::FALSE
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
      it "returns the operand's lexical value as a simple literal" do
        @str.evaluate(RDF::Literal("Hello")).should eql RDF::Literal("Hello")
        @str.evaluate(RDF::Literal(3.1415)).should eql RDF::Literal("3.1415")
      end
    end

    describe ".evaluate(RDF::URI)" do
      it "returns the operand IRI string as a simple literal" do
        @str.evaluate(RDF::DC.title).should eql RDF::Literal(RDF::DC.title.to_s)
      end
    end

    describe ".evaluate(RDF::Term)" do
      it "raises a TypeError" do
        lambda { @str.evaluate(RDF::Node.new) }.should raise_error TypeError
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

  ##########################################################################
  # BINARY OPERATORS

  # @see http://www.w3.org/TR/rdf-sparql-query/#func-logical-or
  # @see http://www.w3.org/TR/rdf-sparql-query/#evaluation
  context "Operator::Or" do
    describe ".evaluate(RDF::Literal::TRUE, RDF::Literal::TRUE)" do
      it "returns RDF::Literal::TRUE" do
        @or.evaluate(RDF::Literal::TRUE, RDF::Literal::TRUE).should eql RDF::Literal::TRUE
      end
    end

    describe ".evaluate(RDF::Literal::TRUE, RDF::Literal::FALSE)" do
      it "returns RDF::Literal::TRUE" do
        @or.evaluate(RDF::Literal::TRUE, RDF::Literal::FALSE).should eql RDF::Literal::TRUE
      end
    end

    describe ".evaluate(RDF::Literal::FALSE, RDF::Literal::TRUE)" do
      it "returns RDF::Literal::TRUE" do
        @or.evaluate(RDF::Literal::FALSE, RDF::Literal::TRUE).should eql RDF::Literal::TRUE
      end
    end

    describe ".evaluate(RDF::Literal::FALSE, RDF::Literal::FALSE)" do
      it "returns RDF::Literal::FALSE" do
        @or.evaluate(RDF::Literal::FALSE, RDF::Literal::FALSE).should eql RDF::Literal::FALSE
      end
    end

    describe ".evaluate(lhs, rhs)" do
      # TODO
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#func-logical-and
  # @see http://www.w3.org/TR/rdf-sparql-query/#evaluation
  context "Operator::And" do
    describe ".evaluate(RDF::Literal::TRUE, RDF::Literal::TRUE)" do
      it "returns RDF::Literal::TRUE" do
        @and.evaluate(RDF::Literal::TRUE, RDF::Literal::TRUE).should eql RDF::Literal::TRUE
      end
    end

    describe ".evaluate(RDF::Literal::TRUE, RDF::Literal::FALSE)" do
      it "returns RDF::Literal::FALSE" do
        @and.evaluate(RDF::Literal::TRUE, RDF::Literal::FALSE).should eql RDF::Literal::FALSE
      end
    end

    describe ".evaluate(RDF::Literal::FALSE, RDF::Literal::TRUE)" do
      it "returns RDF::Literal::FALSE" do
        @and.evaluate(RDF::Literal::FALSE, RDF::Literal::TRUE).should eql RDF::Literal::FALSE
      end
    end

    describe ".evaluate(RDF::Literal::FALSE, RDF::Literal::FALSE)" do
      it "returns RDF::Literal::FALSE" do
        @or.evaluate(RDF::Literal::FALSE, RDF::Literal::FALSE).should eql RDF::Literal::FALSE
      end
    end

    describe ".evaluate(lhs, rhs)" do
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
      it "returns RDF::Literal::TRUE if the terms are equal" do
        #pending # TODO
      end

      it "returns RDF::Literal::FALSE if the terms are not equal" do
        #pending # TODO
      end
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#func-RDFterm-equal
  context "Operator::NotEqual" do
    describe ".evaluate(RDF::Term, RDF::Term)" do
      it "returns RDF::Literal::FALSE if the terms are equal" do
        #pending # TODO
      end

      it "returns RDF::Literal::TRUE if the terms are not equal" do
        #pending # TODO
      end
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#func-sameTerm
  context "Operator::SameTerm" do
    describe ".evaluate(RDF::Term, RDF::Term)" do
      it "returns RDF::Literal::TRUE if the terms are the same" do
        @same_term.evaluate(RDF::Literal(true), RDF::Literal::TRUE).should eql RDF::Literal::TRUE
        @same_term.evaluate(RDF::Literal('a'), RDF::Literal('a')).should eql RDF::Literal::TRUE
      end

      it "returns RDF::Literal::FALSE if the terms are not the same" do
        @same_term.evaluate(RDF::Literal(true), RDF::Literal::FALSE).should eql RDF::Literal::FALSE
        @same_term.evaluate(RDF::Literal('a'), RDF::Literal('b')).should eql RDF::Literal::FALSE
      end
    end

    describe ".evaluate(RDF::Term, nil)" do
      it "raises a TypeError" do
        pending do
          lambda { @same_term.evaluate(RDF::Literal::TRUE, nil) }.should raise_error TypeError # FIXME
        end
      end
    end

    describe ".evaluate(nil, RDF::Term)" do
      it "raises a TypeError" do
        pending do
          lambda { @same_term.evaluate(nil, RDF::Literal::TRUE) }.should raise_error TypeError # FIXME
        end
      end
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#func-langMatches
  context "Operator::LangMatches" do
    describe ".evaluate(language_tag, language_range)" do
      # TODO
    end
  end

  ##########################################################################
  # TERNARY OPERATORS

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

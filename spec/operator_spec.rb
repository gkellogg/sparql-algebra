require File.join(File.dirname(__FILE__), 'spec_helper')

describe SPARQL::Algebra do
  # @see http://www.w3.org/TR/rdf-sparql-query/#OperatorMapping
  before :all do
    @op           = SPARQL::Algebra::Operator
    @op0          = SPARQL::Algebra::Operator::Nullary
    @op1          = SPARQL::Algebra::Operator::Unary
    @op2          = SPARQL::Algebra::Operator::Binary
    @op3          = SPARQL::Algebra::Operator::Ternary
    # Unary operators:
    @not          = SPARQL::Algebra::Operator::Not
    @plus         = SPARQL::Algebra::Operator::Plus
    @minus        = SPARQL::Algebra::Operator::Minus
    @bound        = SPARQL::Algebra::Operator::Bound
    @is_iri       = SPARQL::Algebra::Operator::IsIRI
    @is_blank     = SPARQL::Algebra::Operator::IsBlank
    @is_literal   = SPARQL::Algebra::Operator::IsLiteral
    @str          = SPARQL::Algebra::Operator::Str
    @lang         = SPARQL::Algebra::Operator::Lang
    @datatype     = SPARQL::Algebra::Operator::Datatype
    # Binary operators
    @or           = SPARQL::Algebra::Operator::Or
    @and          = SPARQL::Algebra::Operator::And
    @eq           = SPARQL::Algebra::Operator::Equal
    # TODO: missing binary operators
    @multiply     = SPARQL::Algebra::Operator::Multiply
    @divide       = SPARQL::Algebra::Operator::Divide
    @add          = SPARQL::Algebra::Operator::Add
    @subtract     = SPARQL::Algebra::Operator::Subtract
    # TODO: missing binary operators
    @same_term    = SPARQL::Algebra::Operator::SameTerm
    @lang_matches = SPARQL::Algebra::Operator::LangMatches
    # Ternary operators
    @regex        = SPARQL::Algebra::Operator::Regex
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

    describe "#boolean(RDF::Literal::String)" do
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
      it "returns the operand with its sign unchanged" do
        @plus.evaluate(RDF::Literal(42)).should eql RDF::Literal(42)
        @plus.evaluate(RDF::Literal(42.0)).should eql RDF::Literal(42.0)
        @plus.evaluate(RDF::Literal(BigDecimal('42.0'))).should eql RDF::Literal(BigDecimal('42.0'))
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
      it "returns the operand with its sign reversed" do
        @minus.evaluate(RDF::Literal(42)).should eql RDF::Literal(-42)
        @minus.evaluate(RDF::Literal(-42.0)).should eql RDF::Literal(42.0)
        @minus.evaluate(RDF::Literal(BigDecimal('42.0'))).should eql RDF::Literal(BigDecimal('-42.0'))
      end
    end

    describe ".evaluate(RDF::Literal(0))" do
      it "returns the operand" do
        @minus.evaluate(RDF::Literal(0)).should eql RDF::Literal(0)
      end
    end

    describe ".evaluate(RDF::Literal(BigDecimal('0.0')))" do
      it "returns the operand" do
        @minus.evaluate(RDF::Literal(BigDecimal('0.0'))).should eql RDF::Literal(BigDecimal('0.0'))
      end
    end

    describe ".evaluate(RDF::Literal(NaN))" do
      it "returns the operand" do
        @minus.evaluate(RDF::Literal(nan = 0/0.0)).should be_nan
      end
    end

    describe ".evaluate(RDF::Literal(0.0E0))" do
      it "returns RDF::Literal(-0.0E0)" do
        @minus.evaluate(RDF::Literal(0.0E0)).should eql RDF::Literal(-0.0E0)
      end
    end

    describe ".evaluate(RDF::Literal(-0.0E0))" do
      it "returns RDF::Literal(0.0E0)" do
        @minus.evaluate(RDF::Literal(-0.0E0)).should eql RDF::Literal(0.0E0)
      end
    end

    describe ".evaluate(RDF::Literal(Infinity))" do
      it "returns RDF::Literal(-Infinity)" do
        @minus.evaluate(RDF::Literal(1/0.0)).should eql RDF::Literal(-1/0.0)
      end
    end

    describe ".evaluate(RDF::Literal(-Infinity))" do
      it "returns RDF::Literal(Infinity)" do
        @minus.evaluate(RDF::Literal(-1/0.0)).should eql RDF::Literal(1/0.0)
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

  # @see http://www.w3.org/TR/rdf-sparql-query/#OperatorMapping
  context "Operator::Equal" do
    # @see http://www.w3.org/TR/xpath-functions/#func-compare
    describe ".evaluate(RDF::Literal::Simple, RDF::Literal::Simple)" do
      it "returns RDF::Literal::TRUE if the operands are equal" do
        @eq.evaluate(RDF::Literal('foo'), RDF::Literal('foo')).should eql RDF::Literal::TRUE
      end

      it "returns RDF::Literal::FALSE if the operands are not equal" do
        @eq.evaluate(RDF::Literal('foo'), RDF::Literal('bar')).should eql RDF::Literal::FALSE
      end
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-compare
    describe ".evaluate(RDF::Literal::String, RDF::Literal::String)" do
      it "returns RDF::Literal::TRUE if the operands are equal" do
        @eq.evaluate(RDF::Literal('foo', :datatype => RDF::XSD.string), RDF::Literal('foo', :datatype => RDF::XSD.string)).should eql RDF::Literal::TRUE
      end

      it "returns RDF::Literal::FALSE if the operands are not equal" do
        @eq.evaluate(RDF::Literal('foo', :datatype => RDF::XSD.string), RDF::Literal('bar', :datatype => RDF::XSD.string)).should eql RDF::Literal::FALSE
      end
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-numeric-equal
    describe ".evaluate(RDF::Literal::Numeric, RDF::Literal::Numeric)" do
      it "returns RDF::Literal::TRUE if the operands are identical" do
        @eq.evaluate(RDF::Literal(1), RDF::Literal(1)).should eql RDF::Literal::TRUE
        @eq.evaluate(RDF::Literal(1.0), RDF::Literal(1.0)).should eql RDF::Literal::TRUE
        @eq.evaluate(RDF::Literal(BigDecimal('1')), RDF::Literal(BigDecimal('1'))).should eql RDF::Literal::TRUE
      end

      it "returns RDF::Literal::TRUE if the operands are equal" do
        @eq.evaluate(RDF::Literal(1), RDF::Literal(1.0)).should eql RDF::Literal::TRUE
        @eq.evaluate(RDF::Literal(1), RDF::Literal(BigDecimal('1'))).should eql RDF::Literal::TRUE
        @eq.evaluate(RDF::Literal(1), RDF::Literal(1, :datatype => RDF::XSD.int)).should eql RDF::Literal::TRUE
        @eq.evaluate(RDF::Literal(1, :datatype => RDF::XSD.int), RDF::Literal(1)).should eql RDF::Literal::TRUE
      end

      it "returns RDF::Literal::FALSE if the operands are not equal" do
        @eq.evaluate(RDF::Literal(1), RDF::Literal(2)).should eql RDF::Literal::FALSE
        @eq.evaluate(RDF::Literal(1.0), RDF::Literal(2.0)).should eql RDF::Literal::FALSE
        @eq.evaluate(RDF::Literal(BigDecimal('1')), RDF::Literal(BigDecimal('2'))).should eql RDF::Literal::FALSE
      end
    end

    # For xsd:float and xsd:double values, positive zero and negative zero
    # compare equal. INF equals INF and -INF equals -INF. NaN does not
    # equal itself.
    # @see http://www.w3.org/TR/xpath-functions/#func-numeric-equal
    inf, nan = 1/0.0, 0/0.0
    examples = {
      [:'=', +0.0, +0.0] => true,
      [:'=', +0.0, -0.0] => true,
      [:'=', -0.0, +0.0] => true,
      [:'=', -0.0, -0.0] => true,
      [:'=', +inf, +inf] => true,
      [:'=', +inf, -inf] => false,
      [:'=', -inf, +inf] => false,
      [:'=', -inf, -inf] => true,
      [:'=', nan, nan]   => false,
    }
    examples.each do |input, output|
      describe ".evaluate(RDF::Literal(#{input[1].inspect}), RDF::Literal(#{input[2].inspect}))" do
        it "returns RDF::Literal::#{output.to_s.upcase}" do
          @eq.evaluate(RDF::Literal(input[1]), RDF::Literal(input[2])).should eql RDF::Literal(output)
        end
      end
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-boolean-equal
    describe ".evaluate(RDF::Literal::Boolean, RDF::Literal::Boolean)" do
      it "returns RDF::Literal::TRUE if the operands are equal" do
        @eq.evaluate(RDF::Literal::TRUE, RDF::Literal::TRUE).should eql RDF::Literal::TRUE
        @eq.evaluate(RDF::Literal::FALSE, RDF::Literal::FALSE).should eql RDF::Literal::TRUE
      end

      it "returns RDF::Literal::FALSE if the operands are not equal" do
        @eq.evaluate(RDF::Literal::TRUE, RDF::Literal::FALSE).should eql RDF::Literal::FALSE
      end
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-dateTime-equal
    describe ".evaluate(RDF::Literal::DateTime, RDF::Literal::DateTime)" do
      it "returns RDF::Literal::TRUE if the operands are equal" do
        @eq.evaluate(RDF::Literal('2010-12-31T12:34:56Z', :datatype => RDF::XSD.dateTime), RDF::Literal('2010-12-31T12:34:56Z', :datatype => RDF::XSD.dateTime)).should eql RDF::Literal::TRUE
      end

      it "returns RDF::Literal::FALSE if the operands are not equal" do
        @eq.evaluate(RDF::Literal('2010-12-31T12:34:56Z', :datatype => RDF::XSD.dateTime), RDF::Literal('2010-12-31T12:34:56+01:00', :datatype => RDF::XSD.dateTime)).should eql RDF::Literal::FALSE
      end
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-dateTime-equal
    examples = {
      [:'=', '2002-04-02T12:00:00-01:00', '2002-04-02T17:00:00+04:00'] => true,
      [:'=', '2002-04-02T12:00:00-05:00', '2002-04-02T23:00:00+06:00'] => true,
      [:'=', '2002-04-02T12:00:00-05:00', '2002-04-02T17:00:00-05:00'] => false,
      [:'=', '2002-04-02T12:00:00-05:00', '2002-04-02T12:00:00-05:00'] => true,
      [:'=', '2002-04-02T23:00:00-04:00', '2002-04-03T02:00:00-01:00'] => true,
      [:'=', '1999-12-31T24:00:00-05:00', '2000-01-01T00:00:00-05:00'] => true,
      [:'=', '2005-04-04T24:00:00-05:00', '2005-04-04T00:00:00-05:00'] => false,
    }
    examples.each do |input, output|
      describe ".evaluate(RDF::Literal::DateTime(#{input[1].inspect}), RDF::Literal::DateTime(#{input[2].inspect}))" do
        it "returns RDF::Literal::#{output.to_s.upcase}" do
          #@eq.evaluate(RDF::Literal(input[1], :datatype => RDF::XSD.dateTime), RDF::Literal(input[2], :datatype => RDF::XSD.dateTime)).should eql RDF::Literal(output) # FIXME in RDF.rb 0.3.0
        end
      end
    end

    # @see http://www.w3.org/TR/rdf-sparql-query/#func-RDFterm-equal
    describe ".evaluate(RDF::Literal, RDF::Literal)" do
      it "returns RDF::Literal::TRUE if the operands are equal" do
        @eq.evaluate(*([RDF::Literal('Hello', :language => :en)] * 2)).should eql RDF::Literal::TRUE
        @eq.evaluate(RDF::Literal(:Hello), RDF::Literal(:Hello)).should eql RDF::Literal::TRUE
      end

      it "raises a TypeError if the operands are not equal" do
        lambda { @eq.evaluate(RDF::Literal('Hello'), RDF::Literal('Hello', :language => :en)) }.should raise_error TypeError
        lambda { @eq.evaluate(RDF::Literal('Hello'), RDF::Literal(:Hello)) }.should raise_error TypeError
        lambda { @eq.evaluate(RDF::Literal('Hello'), RDF::Literal::TRUE) }.should raise_error TypeError
        lambda { @eq.evaluate(RDF::Literal('Hello'), RDF::Literal::ZERO) }.should raise_error TypeError
      end
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#OperatorMapping
  context "Operator::NotEqual" do
    # @see http://www.w3.org/TR/xpath-functions/#func-compare
    describe ".evaluate(RDF::Literal::Simple, RDF::Literal::Simple)" do
      # TODO
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-compare
    describe ".evaluate(RDF::Literal::String, RDF::Literal::String)" do
      # TODO
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-not
    # @see http://www.w3.org/TR/xpath-functions/#func-numeric-equal
    describe ".evaluate(RDF::Literal::Numeric, RDF::Literal::Numeric)" do
      # TODO
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-not
    # @see http://www.w3.org/TR/xpath-functions/#func-boolean-equal
    describe ".evaluate(RDF::Literal::Boolean, RDF::Literal::Boolean)" do
      # TODO
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-not
    # @see http://www.w3.org/TR/xpath-functions/#func-dateTime-equal
    describe ".evaluate(RDF::Literal::DateTime, RDF::Literal::DateTime)" do
      # TODO
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#OperatorMapping
  context "Operator::LessThan" do
    # @see http://www.w3.org/TR/xpath-functions/#func-compare
    describe ".evaluate(RDF::Literal::Simple, RDF::Literal::Simple)" do
      # TODO
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-compare
    describe ".evaluate(RDF::Literal::String, RDF::Literal::String)" do
      # TODO
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-numeric-less-than
    describe ".evaluate(RDF::Literal::Numeric, RDF::Literal::Numeric)" do
      # TODO
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-boolean-less-than
    describe ".evaluate(RDF::Literal::Boolean, RDF::Literal::Boolean)" do
      # TODO
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-dateTime-less-than
    describe ".evaluate(RDF::Literal::DateTime, RDF::Literal::DateTime)" do
      # TODO
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#OperatorMapping
  context "Operator::GreaterThan" do
    # @see http://www.w3.org/TR/xpath-functions/#func-compare
    describe ".evaluate(RDF::Literal::Simple, RDF::Literal::Simple)" do
      # TODO
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-compare
    describe ".evaluate(RDF::Literal::String, RDF::Literal::String)" do
      # TODO
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-numeric-greater-than
    describe ".evaluate(RDF::Literal::Numeric, RDF::Literal::Numeric)" do
      # TODO
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-boolean-greater-than
    describe ".evaluate(RDF::Literal::Boolean, RDF::Literal::Boolean)" do
      # TODO
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-dateTime-greater-than
    describe ".evaluate(RDF::Literal::DateTime, RDF::Literal::DateTime)" do
      # TODO
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#OperatorMapping
  context "Operator::LessThanOrEqual" do
    # @see http://www.w3.org/TR/xpath-functions/#func-compare
    describe ".evaluate(RDF::Literal::Simple, RDF::Literal::Simple)" do
      # TODO
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-compare
    describe ".evaluate(RDF::Literal::String, RDF::Literal::String)" do
      # TODO
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-numeric-less-than
    # @see http://www.w3.org/TR/xpath-functions/#func-numeric-equal
    describe ".evaluate(RDF::Literal::Numeric, RDF::Literal::Numeric)" do
      # TODO
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-boolean-less-than
    # @see http://www.w3.org/TR/xpath-functions/#func-boolean-equal
    describe ".evaluate(RDF::Literal::Boolean, RDF::Literal::Boolean)" do
      # TODO
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-dateTime-less-than
    # @see http://www.w3.org/TR/xpath-functions/#func-dateTime-equal
    describe ".evaluate(RDF::Literal::DateTime, RDF::Literal::DateTime)" do
      # TODO
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#OperatorMapping
  context "Operator::GreaterThanOrEqual" do
    # @see http://www.w3.org/TR/xpath-functions/#func-compare
    describe ".evaluate(RDF::Literal::Simple, RDF::Literal::Simple)" do
      # TODO
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-compare
    describe ".evaluate(RDF::Literal::String, RDF::Literal::String)" do
      # TODO
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-numeric-greater-than
    # @see http://www.w3.org/TR/xpath-functions/#func-numeric-equal
    describe ".evaluate(RDF::Literal::Numeric, RDF::Literal::Numeric)" do
      # TODO
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-boolean-greater-than
    # @see http://www.w3.org/TR/xpath-functions/#func-boolean-equal
    describe ".evaluate(RDF::Literal::Boolean, RDF::Literal::Boolean)" do
      # TODO
    end

    # @see http://www.w3.org/TR/xpath-functions/#func-dateTime-greater-than
    # @see http://www.w3.org/TR/xpath-functions/#func-dateTime-equal
    describe ".evaluate(RDF::Literal::DateTime, RDF::Literal::DateTime)" do
      # TODO
    end
  end

  # @see http://www.w3.org/TR/xpath-functions/#func-numeric-multiply
  context "Operator::Multiply" do
    describe ".evaluate(RDF::Literal::Numeric, RDF::Literal::Numeric)" do
      it "returns the arithmetic product of the operands" do
        @multiply.evaluate(RDF::Literal(2), RDF::Literal(1)).should eql RDF::Literal(2)
        @multiply.evaluate(RDF::Literal(2.0), RDF::Literal(1.0)).should eql RDF::Literal(2.0)
        @multiply.evaluate(RDF::Literal(BigDecimal('2')), RDF::Literal(BigDecimal('1'))).should eql RDF::Literal(BigDecimal('2'))
      end
    end

    # For xsd:float or xsd:double values, if one of the operands is a zero
    # and the other is an infinity, NaN is returned. If one of the operands
    # is a non-zero number and the other is an infinity, an infinity with
    # the appropriate sign is returned.
    inf, nan = 1/0.0, 0/0.0
    examples = {
      [:*, 0.0, inf]   => nan,
      [:*, 0.0, -inf]  => nan,
      [:*, inf, 0.0]   => nan,
      [:*, -inf, 0.0]  => nan,
      [:*, 1.0, inf]   => inf,
      [:*, 1.0, -inf]  => -inf,
      [:*, inf, 1.0]   => inf,
      [:*, -inf, 1.0]  => -inf,
      [:*, inf, inf]   => inf,
      [:*, -inf, -inf] => inf,
      [:*, inf, -inf]  => -inf,
      [:*, -inf, inf]  => -inf,
    }
    examples.each do |input, output|
      describe ".evaluate(RDF::Literal(#{input[1].inspect}), RDF::Literal(#{input[2].inspect}))" do
        it "returns RDF::Literal(#{output.inspect})" do
          result = @multiply.evaluate(RDF::Literal(input[1]), RDF::Literal(input[2]))
          if output.nan?
            result.should be_nan
          else
            result.should eql RDF::Literal(output)
          end
        end
      end
    end

    describe ".evaluate(RDF::Term, RDF::Term)" do
      it "raises a TypeError" do
        lambda { @multiply.evaluate(RDF::Literal::TRUE, RDF::Literal::FALSE) }.should raise_error TypeError
      end
    end
  end

  # @see http://www.w3.org/TR/xpath-functions/#func-numeric-divide
  context "Operator::Divide" do
    describe ".evaluate(RDF::Literal::Numeric, RDF::Literal::Numeric)" do
      it "returns the arithmetic quotient of the operands" do
        @divide.evaluate(RDF::Literal(1), RDF::Literal(2)).should eql RDF::Literal(BigDecimal('0.5'))
        @divide.evaluate(RDF::Literal(1.0), RDF::Literal(2.0)).should eql RDF::Literal(0.5)
        @divide.evaluate(RDF::Literal(BigDecimal('1')), RDF::Literal(BigDecimal('2'))).should eql RDF::Literal(BigDecimal('0.5'))
      end
    end

    # For xsd:decimal and xsd:integer operands, if the divisor is (positive
    # or negative) zero, an error is raised.
    # @see http://www.w3.org/TR/xpath-functions/#ERRFOAR0001
    examples = {
      [:/, 1, +0]      => ZeroDivisionError,
      [:/, 1, +0.0]    => ZeroDivisionError,
      [:x, 1, -0.0]    => ZeroDivisionError, # overwrites the previous hash key if :/
    }
    examples.each do |input, output|
      describe ".evaluate(RDF::Literal(#{input[1].inspect}), RDF::Literal(#{input[2].inspect}))" do
        it "raises #{output.inspect}" do
          lambda { @divide.evaluate(RDF::Literal(input[1]), RDF::Literal(input[2])) }.should raise_error(output)
        end
      end

      describe ".evaluate(RDF::Literal(BigDecimal(#{input[1].inspect})), RDF::Literal(#{input[2].inspect}))" do
        it "raises #{output.inspect}" do
          lambda { @divide.evaluate(RDF::Literal(BigDecimal(input[1].to_s)), RDF::Literal(input[2])) }.should raise_error(output)
        end
      end
    end

    # For xsd:float or xsd:double values, a positive number divided by
    # positive zero returns INF. A negative number divided by positive zero
    # returns -INF. Division by negative zero returns -INF and INF,
    # respectively. Positive or negative zero divided by positive or
    # negative zero returns NaN. Also, INF or -INF divided by INF or -INF
    # returns NaN.
    inf, nan = 1/0.0, 0/0.0
    examples = {
      [:/, +1.0, +0.0] => inf,
      [:x, +1.0, -0.0] => -inf, # overwrites the previous hash key if :/
      [:/, -1.0, +0.0] => -inf,
      [:x, -1.0, -0.0] => inf,  # overwrites the previous hash key if :/
      [:/, +0.0, +0.0] => nan,
      [:/, +0.0, -0.0] => nan,
      [:/, -0.0, +0.0] => nan,
      [:/, -0.0, -0.0] => nan,
      [:/, +inf, +inf] => nan,
      [:/, +inf, -inf] => nan,
      [:/, -inf, +inf] => nan,
      [:/, -inf, -inf] => nan,
    }
    examples.each do |input, output|
      describe ".evaluate(RDF::Literal(#{input[1].inspect}), RDF::Literal(#{input[2].inspect}))" do
        it "returns RDF::Literal(#{output.inspect})" do
          result = @divide.evaluate(RDF::Literal(input[1]), RDF::Literal(input[2]))
          if output.nan?
            result.should be_nan
          else
            result.should eql RDF::Literal(output)
          end
        end
      end
    end

    describe ".evaluate(RDF::Term, RDF::Term)" do
      it "raises a TypeError" do
        lambda { @divide.evaluate(RDF::Literal::TRUE, RDF::Literal::FALSE) }.should raise_error TypeError
      end
    end
  end

  # @see http://www.w3.org/TR/xpath-functions/#func-numeric-add
  context "Operator::Add" do
    describe ".evaluate(RDF::Literal::Numeric, RDF::Literal::Numeric)" do
      it "returns the arithmetic sum of the operands" do
        @add.evaluate(RDF::Literal(1), RDF::Literal(1)).should eql RDF::Literal(2)
        @add.evaluate(RDF::Literal(1.0), RDF::Literal(1.0)).should eql RDF::Literal(2.0)
        @add.evaluate(RDF::Literal(BigDecimal('1')), RDF::Literal(BigDecimal('1'))).should eql RDF::Literal(BigDecimal('2'))
      end
    end

    # For xsd:float or xsd:double values, if one of the operands is a zero
    # or a finite number and the other is INF or -INF, INF or -INF is
    # returned. If both operands are INF, INF is returned. If both
    # operands are -INF, -INF is returned. If one of the operands is INF
    # and the other is -INF, NaN is returned.
    inf, nan = 1/0.0, 0/0.0
    examples = {
      [:+, 0.0, inf]   => inf,
      [:+, 0.0, -inf]  => -inf,
      [:+, inf, 0.0]   => inf,
      [:+, -inf, 0.0]  => -inf,
      [:+, inf, inf]   => inf,
      [:+, -inf, -inf] => -inf,
      [:+, inf, -inf]  => nan,
      [:+, -inf, inf]  => nan,
    }
    examples.each do |input, output|
      describe ".evaluate(RDF::Literal(#{input[1].inspect}), RDF::Literal(#{input[2].inspect}))" do
        it "returns RDF::Literal(#{output.inspect})" do
          result = @add.evaluate(RDF::Literal(input[1]), RDF::Literal(input[2]))
          if output.nan?
            result.should be_nan
          else
            result.should eql RDF::Literal(output)
          end
        end
      end
    end

    describe ".evaluate(RDF::Term, RDF::Term)" do
      it "raises a TypeError" do
        lambda { @add.evaluate(RDF::Literal::TRUE, RDF::Literal::FALSE) }.should raise_error TypeError
      end
    end
  end

  # @see http://www.w3.org/TR/xpath-functions/#func-numeric-subtract
  context "Operator::Subtract" do
    describe ".evaluate(RDF::Literal::Numeric, RDF::Literal::Numeric)" do
      it "returns the arithmetic difference of the operands" do
        @subtract.evaluate(RDF::Literal(2), RDF::Literal(1)).should eql RDF::Literal(1)
        @subtract.evaluate(RDF::Literal(2.0), RDF::Literal(1.0)).should eql RDF::Literal(1.0)
        @subtract.evaluate(RDF::Literal(BigDecimal('2')), RDF::Literal(BigDecimal('1'))).should eql RDF::Literal(BigDecimal('1'))
      end
    end

    # For xsd:float or xsd:double values, if one of the operands is a zero
    # or a finite number and the other is INF or -INF, an infinity of the
    # appropriate sign is returned. If both operands are INF or -INF, NaN
    # is returned. If one of the operands is INF and the other is -INF, an
    # infinity of the appropriate sign is returned.
    inf, nan = 1/0.0, 0/0.0
    examples = {
      [:-, 0.0, inf]   => -inf,
      [:-, 0.0, -inf]  => inf,
      [:-, inf, 0.0]   => inf,
      [:-, -inf, 0.0]  => -inf,
      [:-, inf, inf]   => nan,
      [:-, -inf, -inf] => nan,
      [:-, inf, -inf]  => inf,
      [:-, -inf, inf]  => -inf,
    }
    examples.each do |input, output|
      describe ".evaluate(RDF::Literal(#{input[1].inspect}), RDF::Literal(#{input[2].inspect}))" do
        it "returns RDF::Literal(#{output.inspect})" do
          result = @subtract.evaluate(RDF::Literal(input[1]), RDF::Literal(input[2]))
          if output.nan?
            result.should be_nan
          else
            result.should eql RDF::Literal(output)
          end
        end
      end
    end

    describe ".evaluate(RDF::Term, RDF::Term)" do
      it "raises a TypeError" do
        lambda { @subtract.evaluate(RDF::Literal::TRUE, RDF::Literal::FALSE) }.should raise_error TypeError
      end
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#func-RDFterm-equal
  context "Operator::Equal" do
    describe ".evaluate(RDF::Term, RDF::Term)" do
      it "returns RDF::Literal::TRUE if the terms are equal" do
        @eq.evaluate(iri = RDF::URI('mailto:alice@example.org'), iri).should eql RDF::Literal::TRUE
        @eq.evaluate(RDF::Node(:foo), RDF::Node(:foo)).should eql RDF::Literal::TRUE
      end

      it "returns RDF::Literal::FALSE if the terms are not equal" do
        @eq.evaluate(iri = RDF::URI('mailto:alice@example.org'), RDF::URI(iri.to_s.sub('alice', 'bob'))).should eql RDF::Literal::FALSE
        @eq.evaluate(RDF::Node(:foo), RDF::Node(:bar)).should eql RDF::Literal::FALSE
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
    # @see http://www.w3.org/TR/rdf-concepts/#section-blank-nodes
    examples = {
      [RDF::Node(:foo), RDF::Node(:foo)] => true,
      [RDF::Node(:foo), RDF::Node(:bar)] => false,
    }
    examples.each do |input, output|
      describe ".evaluate(RDF::Node(#{input[0].to_sym.inspect}), RDF::Node(#{input[1].to_sym.inspect}))" do
        it "returns RDF::Literal::#{output.to_s.upcase}" do
          @same_term.evaluate(input[0], input[1]).should eql RDF::Literal(output)
        end
      end
    end

    # @see http://www.w3.org/TR/rdf-concepts/#section-Graph-URIref
    examples = {
      [RDF::DC.title, RDF::DC.title.dup] => true,
      [RDF::DC.title, RDF::DC11.title]   => false,
    }
    examples.each do |input, output|
      describe ".evaluate(RDF::URI(#{input[0].to_s.inspect}), RDF::URI(#{input[1].to_s.inspect}))" do
        it "returns RDF::Literal::#{output.to_s.upcase}" do
          @same_term.evaluate(input[0], input[1]).should eql RDF::Literal(output)
        end
      end
    end

    # @see http://www.w3.org/TR/rdf-concepts/#section-Literal-Equality
    examples = {
      [RDF::Literal('foo'), RDF::Literal('foo')] => true,
      [RDF::Literal('foo'), RDF::Literal('bar')] => false,
    }
    examples.each do |input, output|
      describe ".evaluate(RDF::Literal(#{input[0].to_s.inspect}), RDF::Literal(#{input[1].to_s.inspect}))" do
        it "returns RDF::Literal::#{output.to_s.upcase}" do
          @same_term.evaluate(input[0], input[1]).should eql RDF::Literal(output)
        end
      end
    end

    # @see http://www.w3.org/TR/rdf-sparql-query/#func-sameTerm
    describe ".evaluate(RDF::Term, RDF::Term)" do
      it "returns RDF::Literal::TRUE if the terms are the same" do
        @same_term.evaluate(RDF::Literal(true), RDF::Literal::TRUE).should eql RDF::Literal::TRUE
        @same_term.evaluate(RDF::Literal('a'), RDF::Literal('a')).should eql RDF::Literal::TRUE
      end

      it "returns RDF::Literal::FALSE if the terms are not the same" do
        @same_term.evaluate(RDF::Literal(true), RDF::Literal::FALSE).should eql RDF::Literal::FALSE
        @same_term.evaluate(RDF::Literal('a'), RDF::Literal('b')).should eql RDF::Literal::FALSE
        #@same_term.evaluate(RDF::Literal(1), RDF::Literal(1.0)).should eql RDF::Literal::FALSE # FIXME
      end
    end

    describe ".evaluate(RDF::Term, nil)" do
      it "raises a TypeError" do
        lambda { @same_term.evaluate(RDF::Literal::TRUE, nil) }.should raise_error TypeError
      end
    end

    describe ".evaluate(nil, RDF::Term)" do
      it "raises a TypeError" do
        lambda { @same_term.evaluate(nil, RDF::Literal::TRUE) }.should raise_error TypeError
      end
    end
  end

  # @see http://www.w3.org/TR/rdf-sparql-query/#func-langMatches
  context "Operator::LangMatches" do
    examples = {
      ['', '*']               => false,
      ['en', '*']             => true,
      ['en', 'en']            => true,
      ['en', 'EN']            => true,
      ['EN', 'en']            => true,
      ['en-US', 'en']         => true,
      # @see http://www.w3.org/TR/rdf-sparql-query/#func-langMatches
      ['en', 'FR']            => false,
      ['fr', 'FR']            => true,
      ['fr-BE', 'FR']         => true,
      ['', 'FR']              => false,
      # @see http://tools.ietf.org/html/rfc4647#section-3.3.1
      ['de-DE-1996', 'de-de'] => true,
      ['de-Deva', 'de-de']    => false,
      ['de-Latn-DE', 'de-de'] => false,
    }
    examples.each do |input, output|
      describe ".evaluate(RDF::Literal(#{input[0].inspect}), RDF::Literal(#{input[1].inspect}))" do
        it "returns RDF::Literal::#{output.to_s.upcase}" do
          @lang_matches.evaluate(RDF::Literal(input[0]), RDF::Literal(input[1])).should eql RDF::Literal(output)
        end
      end
    end

    describe ".evaluate(RDF::Literal, nil)" do
      it "raises a TypeError" do
        lambda { @lang_matches.evaluate(RDF::Literal('en'), nil) }.should raise_error TypeError
      end
    end

    describe ".evaluate(nil, RDF::Literal)" do
      it "raises a TypeError" do
        lambda { @lang_matches.evaluate(nil, RDF::Literal('en')) }.should raise_error TypeError
      end
    end

    describe ".evaluate(RDF::Term, RDF::Term)" do
      it "raises a TypeError" do
        lambda { @lang_matches.evaluate(RDF::Node.new, RDF::Node.new) }.should raise_error TypeError
        lambda { @lang_matches.evaluate(RDF::DC.title, RDF::DC.title) }.should raise_error TypeError
      end
    end
  end

  ##########################################################################
  # TERNARY OPERATORS

  # @see http://www.w3.org/TR/rdf-sparql-query/#funcex-regex
  # @see http://www.w3.org/TR/xpath-functions/#func-matches
  context "Operator::Regex" do
    examples = {
      # @see http://www.w3.org/TR/rdf-sparql-query/#restrictString
      ["SPARQL Tutorial", '^SPARQL', '']                   => true,
      ["The Semantic Web", '^SPARQL', '']                  => false,
      ["SPARQL Tutorial", 'web', 'i']                      => false,
      ["The Semantic Web", 'web', 'i'  ]                   => true,
      # @see http://www.w3.org/TR/rdf-sparql-query/#func-str
      ["<mailto:alice@work.example>", '@work.example', ''] => true,
      ["<mailto:bob@home.example>", '@work.example', '']   => false,
      # @see http://www.w3.org/TR/rdf-sparql-query/#funcex-regex
      ["Alice", '^ali', 'i']                               => true,
      ["Bob", '^ali', 'i']                                 => false,
      # @see http://www.w3.org/TR/xpath-functions/#func-matches
      ["abracadabra", 'bra', '']                           => true,
      ["abracadabra", '^a.*a$', '']                        => true,
      ["abracadabra", '^bra', '']                          => false,
      # @see http://www.w3.org/TR/xpath-functions/#flags
      ["helloworld", 'hello world', 'x']                   => true,
      ["helloworld", 'hello[ ]world', 'x']                 => false,
      #["hello world", 'hello\ sworld', 'x']                => true, # FIXME
      ["hello world", 'hello world', 'x']                  => false,
    }
    examples.each do |input, output|
      describe ".evaluate(RDF::Literal(#{input[0].inspect}), RDF::Literal(#{input[1].inspect}), RDF::Literal(#{input[2].inspect}))" do
        it "returns RDF::Literal::#{output.to_s.upcase}" do
          @regex.evaluate(RDF::Literal(input[0]), RDF::Literal(input[1]), RDF::Literal(input[2])).should eql RDF::Literal(output)
        end
      end
    end

    describe ".evaluate(RDF::Term, RDF::Term, RDF::Term)" do
      it "raises a TypeError" do
        lambda { @regex.evaluate(*([RDF::Node.new] * 3)) }.should raise_error TypeError
        lambda { @regex.evaluate(*([RDF::DC.title] * 3)) }.should raise_error TypeError
      end
    end
  end
end

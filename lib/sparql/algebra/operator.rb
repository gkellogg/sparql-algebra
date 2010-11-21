module SPARQL; module Algebra
  ##
  # A SPARQL operator.
  #
  # @abstract
  class Operator
    include Expression

    # Unary operators
    autoload :Not,         'sparql/algebra/operator/not'
    autoload :Plus,        'sparql/algebra/operator/plus'
    autoload :Minus,       'sparql/algebra/operator/minus'
    autoload :Bound,       'sparql/algebra/operator/bound'
    autoload :IsBlank,     'sparql/algebra/operator/is_blank'
    autoload :IsIRI,       'sparql/algebra/operator/is_iri'
    autoload :IsLiteral,   'sparql/algebra/operator/is_literal'
    autoload :Str,         'sparql/algebra/operator/str'
    autoload :Lang,        'sparql/algebra/operator/lang'
    autoload :Datatype,    'sparql/algebra/operator/datatype'

    # Binary operators
    autoload :Or,          'sparql/algebra/operator/or'
    autoload :And,         'sparql/algebra/operator/and'
    autoload :SameTerm,    'sparql/algebra/operator/same_term'
    autoload :LangMatches, 'sparql/algebra/operator/lang_matches'

    ##
    # Returns an operator class for the given operator `name`.
    #
    # @param  [Symbol, #to_s]  name
    # @param  [Integer, #to_i] arity
    # @return [Class] an operator class, or `nil` if an operator was not found
    def self.for(name, arity = nil)
      # TODO: refactor this to dynamically introspect loaded operator classes.
      case (name.to_s.downcase.to_sym rescue nil)
        when :not, :'!'  then Not
        when :plus, :+   then Plus
        when :minus, :-  then Minus
        when :bound      then Bound
        when :isblank    then IsBlank
        when :isiri      then IsIRI
        when :isuri      then IsIRI # alias
        when :isliteral  then IsLiteral
        when :str        then Str
        when :lang       then Lang
        when :datatype   then Datatype
        when :or, :'||'  then Or
        when :and, :'&&' then And
        when :sameterm   then SameTerm
        else nil # not found
      end
    end

    ##
    # @param  [Array<RDF::Term>] args
    # @return [RDF::Term]
    # @see    Operator#evaluate
    def self.evaluate(*args)
      self.new(*args).evaluate(RDF::Query::Solution.new)
    end

    ##
    # @param  [Hash{Symbol => Object}] options
    #   any additional options
    def initialize(options = {})
      raise ArgumentError, "expected Hash, but got #{options.inspect}" unless options.is_a?(Hash)
      @options  = options.dup
      @operands = [] unless @operands
    end

    ##
    # Any additional options for this operator.
    #
    # @return [Hash]
    attr_reader :options

    ##
    # The operands to this operator.
    #
    # @return [Array]
    attr_reader :operands

    ##
    # Returns the operand at the given `index`.
    #
    # @param  [Integer] index
    #   an operand index in the range `(0...(operands.count))`
    # @return [RDF::Term]
    def operand(index = 0)
      operands[index]
    end

    ##
    # Returns `true` if any of the operands are variables, `false`
    # otherwise.
    #
    # @return [Boolean] `true` or `false`
    # @see    #constant?
    def variable?
      operands.any? { |operand| operand.is_a?(Variable) }
    end

    ##
    # Returns `true` if none of the operands are variables, `false`
    # otherwise.
    #
    # @return [Boolean] `true` or `false`
    # @see    #variable?
    def constant?
      !(variable?)
    end

    ##
    # @param  [RDF::Query::Solution, #[]] bindings
    #   a query solution containing zero or more variable bindings
    # @return [RDF::Term]
    # @abstract
    def evaluate(bindings = {})
      raise NotImplementedError, "#{self.class}#evaluate"
    end

    ##
    # Returns the SPARQL S-Expression (SSE) representation of this operator.
    #
    # @return [Array]
    # @see    http://openjena.org/wiki/SSE
    def to_sse
      operator = [self.class.const_get(:NAME)].flatten.first
      [operator, *(operands || []).map(&:to_sse)]
    end

    ##
    # Returns a developer-friendly representation of this operator.
    #
    # @return [String]
    def inspect
      sprintf("#<%s:%#0x(%s)>", self.class.name, __id__, operands.map(&:inspect).join(', '))
    end

  protected

    ##
    # Returns the effective boolean value (EBV) of the given `literal`.
    #
    # @param  [RDF::Literal] literal
    # @return [RDF::Literal::Boolean] `true` or `false`
    # @raise  [TypeError] if the literal could not be coerced to an `RDF::Literal::Boolean`
    # @see    http://www.w3.org/TR/rdf-sparql-query/#ebv
    def boolean(literal)
      case literal
        when FalseClass then RDF::Literal::FALSE
        when TrueClass  then RDF::Literal::TRUE
        # If the argument is a typed literal with a datatype of
        # `xsd:boolean`, the EBV is the value of that argument.
        # However, the EBV of any literal whose type is `xsd:boolean` is
        # false if the lexical form is not valid for that datatype.
        when RDF::Literal::Boolean
          RDF::Literal(literal.valid? && literal.true?)
        # If the argument is a numeric type or a typed literal with a
        # datatype derived from a numeric type, the EBV is false if the
        # operand value is NaN or is numerically equal to zero; otherwise
        # the EBV is true.
        # However, the EBV of any literal whose type is numeric is
        # false if the lexical form is not valid for that datatype.
        when RDF::Literal::Numeric
          RDF::Literal(literal.valid? && !(literal.zero?) && !(literal.respond_to?(:nan?) && literal.nan?))
        # If the argument is a plain literal or a typed literal with a
        # datatype of `xsd:string`, the EBV is false if the operand value
        # has zero length; otherwise the EBV is true.
        else case
          when literal.is_a?(RDF::Literal) && (literal.plain? || literal.datatype.eql?(RDF::XSD.string))
            RDF::Literal(!(literal.value.empty?))
        # All other arguments, including unbound arguments, produce a type error.
          else raise TypeError, "could not coerce #{literal.inspect} to an RDF::Literal::Boolean"
        end
      end
    end

  private

    @@subclasses = [] # @private

    ##
    # @private
    # @return [void]
    def self.inherited(child)
      @@subclasses << child unless child.superclass.equal?(Operator) # grandchildren only
      super
    end

    ##
    # A SPARQL nullary operator.
    #
    # Operators of this kind take no operands.
    #
    # @abstract
    class Nullary < Operator
      ARITY = 0

      ##
      # @param  [Hash{Symbol => Object}] options
      #   any additional options (see {Operator#initialize})
      def initialize(options = {})
        super(options)
      end
    end # Nullary

    ##
    # A SPARQL unary operator.
    #
    # Operators of this kind take one operand.
    #
    # @abstract
    class Unary < Operator
      ARITY = 1

      ##
      # @param  [RDF::Term] arg
      #   the operand
      # @param  [Hash{Symbol => Object}] options
      #   any additional options (see {Operator#initialize})
      def initialize(arg, options = {})
        @operands = [arg]
        super(options)
      end
    end # Unary

    ##
    # A SPARQL binary operator.
    #
    # Operators of this kind take two operands.
    #
    # @abstract
    class Binary < Operator
      ARITY = 2

      ##
      # @param  [RDF::Term] arg1
      #   the first operand
      # @param  [RDF::Term] arg2
      #   the second operand
      # @param  [Hash{Symbol => Object}] options
      #   any additional options (see {Operator#initialize})
      def initialize(arg1, arg2, options = {})
        @operands = [arg1, arg2]
        super(options)
      end
    end # Binary

    ##
    # A SPARQL ternary operator.
    #
    # Operators of this kind take three operands.
    #
    # @abstract
    class Ternary < Operator
      ARITY = 3

      ##
      # @param  [RDF::Term] arg1
      #   the first operand
      # @param  [RDF::Term] arg2
      #   the second operand
      # @param  [RDF::Term] arg3
      #   the third operand
      # @param  [Hash{Symbol => Object}] options
      #   any additional options (see {Operator#initialize})
      def initialize(arg1, arg2, arg3, options = {})
        @operands = [arg1, arg2, arg3]
        super(options)
      end
    end # Ternary
  end # Operator
end; end # SPARQL::Algebra

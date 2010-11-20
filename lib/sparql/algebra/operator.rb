module SPARQL; module Algebra
  ##
  # A SPARQL operator.
  #
  # @abstract
  class Operator
    autoload :Bound,     'sparql/algebra/operator/bound'
    autoload :IsBlank,   'sparql/algebra/operator/is_blank'
    autoload :IsIRI,     'sparql/algebra/operator/is_iri'
    autoload :IsLiteral, 'sparql/algebra/operator/is_literal'
    autoload :Str,       'sparql/algebra/operator/str'

    ##
    # @param  [Array<Object>] args
    # @return [RDF::Value]
    # @see    Operator#evaluate
    def self.evaluate(*args)
      self.new(*args).evaluate(RDF::Query::Solution.new)
    end

    ##
    # @param  [Hash{Symbol => Object}] options
    #   any additional options
    def initialize(options = {})
      raise ArgumentError, "expected Hash, but got #{options.inspect}" unless options.is_a?(Hash)
      @options = options.dup
    end

    ##
    # Any additional options for this operator.
    #
    # @return [Hash]
    attr_reader :options

    ##
    # @param  [RDF::Query::Solution] solution
    #   a query solution containing zero or more variable bindings
    # @return [RDF::Value]
    # @abstract
    def evaluate(solution)
      raise NotImplementedError, "#{self.class}#evaluate"
    end

    ##
    # A SPARQL nullary operator.
    #
    # Operators of this kind take no arguments.
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
    # Operators of this kind take one argument.
    #
    # @abstract
    class Unary < Operator
      ARITY = 1

      ##
      # @param  [Object] arg
      # @param  [Hash{Symbol => Object}] options
      #   any additional options (see {Operator#initialize})
      def initialize(arg, options = {})
        @arg = arg
        super(options)
      end
    end # Unary

    ##
    # A SPARQL binary operator.
    #
    # Operators of this kind take two arguments.
    #
    # @abstract
    class Binary < Operator
      ARITY = 2

      ##
      # @param  [Object] arg1
      # @param  [Object] arg2
      # @param  [Hash{Symbol => Object}] options
      #   any additional options (see {Operator#initialize})
      def initialize(arg1, arg2, options = {})
        @arg1, @arg2 = arg1, arg2
        super(options)
      end
    end # Binary

    ##
    # A SPARQL ternary operator.
    #
    # Operators of this kind take three arguments.
    #
    # @abstract
    class Ternary < Operator
      ARITY = 3

      ##
      # @param  [Object] arg1
      # @param  [Object] arg2
      # @param  [Object] arg3
      # @param  [Hash{Symbol => Object}] options
      #   any additional options (see {Operator#initialize})
      def initialize(arg1, arg2, arg3, options = {})
        @arg1, @arg2, @arg3 = arg1, arg2, arg3
        super(options)
      end
    end # Ternary
  end # Operator
end; end # SPARQL::Algebra

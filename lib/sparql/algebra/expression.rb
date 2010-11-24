module SPARQL; module Algebra
  ##
  # A SPARQL algebra expression.
  #
  # @abstract
  module Expression
    ##
    # @example
    #   Expression.parse('(isLiteral 3.1415)')
    #
    # @param  [String] sse
    #   a SPARQL S-Expression (SSE) string
    # @return [Expression]
    def self.parse(sse)
      begin
        require 'sxp' # @see http://rubygems.org/gems/sxp
      rescue LoadError
        abort "SPARQL::Algebra::Expression.parse requires the SXP gem (hint: `gem install sxp')."
      end
      self.new(SXP::Reader::SPARQL.read(sse))
    end

    ##
    # @example
    #   Expression.for(:isLiteral, RDF::Literal(3.1415))
    #   Expression[:isLiteral, RDF::Literal(3.1415)]
    #
    # @param  [Array] sse
    #   a SPARQL S-Expression (SSE) form
    # @return [Expression]
    def self.for(*sse)
      self.new(sse)
    end
    class << self; alias_method :[], :for; end

    ##
    # @example
    #   Expression.new([:isLiteral, RDF::Literal(3.1415)], :version => 1.0)
    #
    # @param  [Array] sse
    #   a SPARQL S-Expression (SSE) form
    # @param  [Hash{Symbol => Object}] options
    # @return [Expression]
    # @raise  [TypeError] if any of the operands is invalid
    def self.new(sse, options = {})
      raise ArgumentError, "invalid SPARQL::Algebra::Expression form: #{sse.inspect}" unless sse.is_a?(Array)

      operator = Operator.for(sse.first, sse.length - 1)
      raise ArgumentError, "invalid SPARQL::Algebra::Expression operator: #{sse.first.inspect}" unless operator

      operands = sse[1..-1].map do |operand|
        case operand
          when Array
            self.new(operand, options)
          when Operator, Variable, RDF::Term
            operand
          when TrueClass, FalseClass, Numeric, String, DateTime, Date, Time, Symbol
            RDF::Literal(operand)
          else raise TypeError, "invalid SPARQL::Algebra::Expression operand: #{operand.inspect}"
        end
      end

      operator.new(*operands)
    end

    ##
    # Returns `false`.
    #
    # @return [Boolean] `true` or `false`
    # @see    #variable?
    def variable?
      false
    end

    ##
    # Returns `true`.
    #
    # @return [Boolean] `true` or `false`
    # @see    #variable?
    def constant?
      !(variable?)
    end

    ##
    # Returns an optimized version of this expression.
    #
    # This is the default implementation, which simply returns `self`.
    # Subclasses can override this method in order to implement something
    # more useful.
    #
    # @return [Expression] `self`
    def optimize
      self
    end

    ##
    # Evaluates this expression using the given variable `bindings`.
    #
    # This is the default implementation, which simply returns `self`.
    # Subclasses can override this method in order to implement something
    # more useful.
    #
    # @param  [RDF::Query::Solution, #[]] bindings
    # @return [Expression] `self`
    def evaluate(bindings = {})
      self
    end

    ##
    # Returns the SPARQL S-Expression (SSE) representation of this expression.
    #
    # This is the default implementation, which simply returns `self`.
    # Subclasses can override this method in order to implement something
    # more useful.
    #
    # @return [Array] `self`
    # @see    http://openjena.org/wiki/SSE
    def to_sse
      self
    end
  end # Expression
end; end # SPARQL::Algebra

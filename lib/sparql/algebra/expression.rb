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
    # @param  [Hash{Symbol => Object}] options
    #   any additional options (see {Operator#initialize})
    # @return [Expression]
    def self.parse(sse, options = {})
      begin
        require 'sxp' # @see http://rubygems.org/gems/sxp
      rescue LoadError
        abort "SPARQL::Algebra::Expression.parse requires the SXP gem (hint: `gem install sxp')."
      end
      self.new(SXP::Reader::SPARQL.read(sse), options)
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
    #   any additional options (see {Operator#initialize})
    # @return [Expression]
    # @raise  [TypeError] if any of the operands is invalid
    def self.new(sse, options = {})
      raise ArgumentError, "invalid SPARQL::Algebra::Expression form: #{sse.inspect}" unless sse.is_a?(Array)

      operator = Operator.for(sse.first, sse.length - 1)
      unless operator
        return case sse.first
        when Array
          debug("Map array elements #{sse}", options)
          sse.map {|s| self.new(s, options.merge(:depth => options[:depth].to_i + 1))}
        else
          debug("No operator found for #{sse.first}", options)
          sse.map do |s|
            s.is_a?(Array) ?
              self.new(s, options.merge(:depth => options[:depth].to_i + 1)) :
              s
          end
        end
      end

      operands = sse[1..-1].map do |operand|
        debug("Operator=#{operator.inspect}, Operand=#{operand.inspect}", options)
        case operand
          when Array
            self.new(operand, options.merge(:depth => options[:depth].to_i + 1))
          when Operator, Variable, RDF::Term
            operand
          when TrueClass, FalseClass, Numeric, String, DateTime, Date, Time, Symbol
            RDF::Literal(operand)
          else raise TypeError, "invalid SPARQL::Algebra::Expression operand: #{operand.inspect}"
        end
      end

      debug("#{operator.inspect}(#{operands.map(&:inspect).join(',')})", options)
      operands << options unless options.empty?
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
    
    private
    ##
    # Progress output when debugging
    # @param [String] str
    def self.debug(message, options = {})
      depth = options[:depth] || 0
      $stderr.puts("#{' ' * depth}#{message}") if options[:debug]
    end
  end # Expression
end; end # SPARQL::Algebra

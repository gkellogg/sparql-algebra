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
          when Operator, Variable, RDF::Term, Symbol
            operand
          when TrueClass, FalseClass, Numeric, String, DateTime, Date, Time
            RDF::Literal(operand)
          else raise TypeError, "invalid SPARQL::Algebra::Expression operand: #{operand.inspect}"
        end
      end

      debug("#{operator.inspect}(#{operands.map(&:inspect).join(',')})", options)
      options.delete_if {|k, v| [:debug, :depth].include?(k) }
      operands << options unless options.empty?
      operator.new(*operands)
    end

    ##
    # Casts operand as the specified datatype
    #
    # @param [RDF::URI] datatype
    #   Datatype to evaluate, one of:
    #   xsd:integer, xsd:decimal xsd:float, xsd:double, xsd:string, xsd:boolean, or xsd:dateTime
    # @param [RDF::Term] value
    #   Value, which should be a typed literal, where the type must be that specified
    # @raise [TypeError] if datatype is not a URI or value cannot be cast to datatype
    # @return [Boolean]
    # @see http://www.w3.org/TR/rdf-sparql-query/#FunctionMapping
    def self.cast(datatype, value)
      case datatype
      when RDF::XSD.dateTime
        case value
        when RDF::Literal::DateTime, RDF::Literal::Date, RDF::Literal::Time
          RDF::Literal.new(value, :datatype => datatype)
        when RDF::Literal::Numeric, RDF::Literal::Boolean, RDF::URI, RDF::Node
          raise TypeError, "Value #{value.inspect} cannot be cast as #{datatype}"
        else
          RDF::Literal.new(value.value, :datatype => datatype, :validate => true)
        end
      when RDF::XSD.float, RDF::XSD.double
        case value
        when RDF::Literal::Numeric, RDF::Literal::Boolean
          RDF::Literal.new(value, :datatype => datatype)
        when RDF::Literal::DateTime, RDF::Literal::Date, RDF::Literal::Time, RDF::URI, RDF::Node
          raise TypeError, "Value #{value.inspect} cannot be cast as #{datatype}"
        else
          RDF::Literal.new(value.value, :datatype => datatype, :validate => true)
        end
      when RDF::XSD.boolean
        case value
        when RDF::Literal::Boolean
          value
        when RDF::Literal::Numeric
          RDF::Literal::Boolean.new(value.value != 0)
        when RDF::Literal::DateTime, RDF::Literal::Date, RDF::Literal::Time, RDF::URI, RDF::Node
          raise TypeError, "Value #{value.inspect} cannot be cast as #{datatype}"
        else
          RDF::Literal.new(!value.to_s.empty?, :datatype => datatype, :validate => true)
        end
      when RDF::XSD.decimal, RDF::XSD.integer
        case value
        when RDF::Literal::Integer, RDF::Literal::Decimal, RDF::Literal::Boolean
          RDF::Literal.new(value, :datatype => datatype)
        when RDF::Literal::DateTime, RDF::Literal::Date, RDF::Literal::Time, RDF::URI, RDF::Node
          raise TypeError, "Value #{value.inspect} cannot be cast as #{datatype}"
        else
          RDF::Literal.new(value.value, :datatype => datatype, :validate => true)
        end
      when RDF::XSD.string
         RDF::Literal.new(value, :datatype => datatype)
      else
        raise TypeError, "Expected datatype (#{datatype}) to be an XSD type"
      end
    rescue
      raise TypeError, $!.message
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
    
    def debug(message, options = {})
      Expression.debug(message, options)
    end
  end # Expression
end; end # SPARQL::Algebra

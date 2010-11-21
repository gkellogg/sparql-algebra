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
    #
    # @param  [Array] sse
    #   a SPARQL S-Expression (SSE) form
    # @return [Expression]
    def self.for(*sse)
      self.new(sse)
    end

    ##
    # @example
    #   Expression.new([:isLiteral, RDF::Literal(3.1415)], :version => 1.0)
    #
    # @param  [Array] sse
    #   a SPARQL S-Expression (SSE) form
    # @param  [Hash{Symbol => Object}] options
    # @return [Expression]
    def self.new(sse, options = {})
      raise ArgumentError, "invalid SPARQL::Algebra::Expression form: #{sse.inspect}" unless sse.is_a?(Array)

      operator = Operator.for(sse.first)
      raise ArgumentError, "invalid SPARQL::Algebra::Expression operator: #{sse.first.inspect}" unless operator

      operands = sse[1..-1].map do |operand|
        case operand
          when Operator
            operand
          when Array
            self.new(operand, options)
          when RDF::Term
            operand
          when TrueClass, FalseClass, Numeric, String, DateTime, Date, Time
            RDF::Literal(operand)
          when Symbol then case
            when operand.to_s[0] == ?? # for convenience
              Variable.new(operand.to_s[1..-1])
            else
              RDF::Literal(operand)
          end
          else raise ArgumentError, "invalid SPARQL::Algebra::Expression operand: #{operand.inspect}"
        end
      end

      operator.new(*operands)
    end
  end # Expression
end; end # SPARQL::Algebra

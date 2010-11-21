module SPARQL; module Algebra
  ##
  # A SPARQL algebra expression.
  #
  # @abstract
  module Expression
    ##
    # @example
    #   Expression.for(:isLiteral, RDF::Literal(3.1415))
    #
    # @param  [Array] sse
    #   a SPARQL S-Expression (SSE) form
    # @return [Operator]
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
    # @return [Operator]
    def self.new(sse, options = {})
      operator = Operator.for(sse.first)
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
                RDF::Query::Variable.new(operand.to_s[1..-1])
              else
                RDF::Literal(operand)
            end
          else
            raise ArgumentError, "invalid SPARQL::Algebra::Expression operand: #{operand.inspect}"
        end
      end
      operator.new(*operands)
    end
  end # Expression
end; end # SPARQL::Algebra

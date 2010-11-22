module SPARQL; module Algebra
  class Operator
    ##
    # The SPARQL `datatype` operator.
    #
    # @see http://www.w3.org/TR/rdf-sparql-query/#func-datatype
    class Datatype < Operator::Unary
      NAME = :datatype

      ##
      # Initializes a new operator instance.
      #
      # @param  [RDF::Literal] literal
      #   a typed or simple RDF literal
      # @param  [Hash{Symbol => Object}] options
      #   any additional options (see {Operator#initialize})
      # @raise  [TypeError] if any operand is invalid
      def initialize(literal, options = {})
        super
      end

      ##
      # Returns the datatype IRI of the operand.
      #
      # If the operand is a simple literal, returns a datatype of
      # `xsd:string`.
      #
      # @param  [RDF::Query::Solution, #[]] bindings
      # @return [RDF::URI] the datatype IRI, or `xsd:string` for simple literals
      # @raise  [TypeError] if the operand is not a typed or simple `RDF::Literal`
      def evaluate(bindings = {})
        case literal = operand.evaluate(bindings)
          when RDF::Literal then case
            when literal.typed?  then RDF::URI(literal.datatype)
            when literal.simple? then RDF::XSD.string
            else raise TypeError, "expected a typed or simple RDF::Literal, but got #{literal.inspect}"
          end
          else raise TypeError, "expected an RDF::Literal, but got #{literal.inspect}"
        end
      end
    end # Datatype
  end # Operator
end; end # SPARQL::Algebra

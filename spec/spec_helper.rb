require "bundler/setup"
require 'sparql/algebra'
require 'rdf/spec'

RSpec.configure do |config|
  config.include(RDF::Spec::Matchers)
  config.exclusion_filter = {:ruby => lambda { |version|
    RUBY_VERSION.to_s !~ /^#{version}/
  }}
end

include SPARQL::Algebra

begin
  require 'sxp' # @see http://rubygems.org/gems/sxp
rescue LoadError
  abort "SPARQL::Algebra specs require the SXP gem (hint: `gem install sxp')."
end

def sse_examples(filename)
  input = File.read(File.join(File.dirname(__FILE__), filename))
  input.gsub!(/\s\-INF/, " \"-INF\"^^<#{RDF::XSD.double}>") # FIXME in SXP.rb
  input.gsub!(/\s\+INF/, " \"INF\"^^<#{RDF::XSD.double}>")  # FIXME in SXP.rb
  input.gsub!(/\sNaN/,  " \"NaN\"^^<#{RDF::XSD.double}>")   # FIXME in SXP.rb
  datatypes = {
    'xsd:double'   => RDF::XSD.double,
    'xsd:float'    => RDF::XSD.float,
    'xsd:integer'  => RDF::XSD.integer,
    'xsd:int'      => RDF::XSD.int,
    'xsd:decimal'  => RDF::XSD.decimal,
    'xsd:string'   => RDF::XSD.string,
    'xsd:token'    => RDF::XSD.token,
    'xsd:boolean'  => RDF::XSD.boolean,
    'xsd:dateTime' => RDF::XSD.dateTime,
  }
  datatypes.each { |qname, uri| input.gsub!(qname, "<#{uri}>") } # FIXME in SXP.rb
  examples = SXP::Reader::SPARQL.read_all(input)
  examples.inject({}) do |result, (tag, input, output)|
    output = case output
      when :TypeError         then TypeError
      when :ZeroDivisionError then ZeroDivisionError
      else output
    end
    result.merge(input => output)
  end
end

def verify(examples)
  examples.each do |input, output|
    describe ".evaluate(#{input[1..-1].map { |term| repr(term) }.join(', ')})" do
      if output.is_a?(Class)
        it "raises #{output.inspect}" do
          lambda { @op.evaluate(*input[1..-1]) }.should raise_error(output)
        end
      else
        it "returns #{repr(output)}" do
          result = @op.evaluate(*input[1..-1])
          if output.is_a?(RDF::Literal::Double) && output.nan?
            result.should be_nan
          else
            result.should eql output
          end
        end
      end
    end
  end
end

def repr(term)
  case term
    when RDF::Node
      "RDF::Node(#{term.to_sym.inspect})"
    when RDF::URI
      "RDF::URI(#{term.to_s.inspect})"
    when RDF::Literal then case
      when term.simple?
        "RDF::Literal(#{term.to_s.inspect})"
      when term.has_language?
        "RDF::Literal(#{term.to_s.inspect}@#{term.language})"
      when term.datatype.eql?(RDF::XSD.string)
        "RDF::Literal::String(#{term.to_s.inspect})"
      when term.is_a?(RDF::Literal::Token)
        "RDF::Literal::Token(#{term.to_s.inspect})"
      when term.is_a?(RDF::Literal::Boolean)
        "RDF::Literal::#{term.true? ? 'TRUE' : 'FALSE'}"
      when term.datatype.eql?(RDF::XSD.float)
        "RDF::Literal::Float(#{term.to_f.inspect})"
      when term.is_a?(RDF::Literal::Numeric)
        value = case term
          when RDF::Literal::Double  then term.to_f.inspect
          when RDF::Literal::Decimal then "BigDecimal(#{term.to_f.inspect})"
          when RDF::Literal::Integer then term.to_i.inspect
          else term.datatype.inspect
        end
        "RDF::Literal(#{value})"
      when term.is_a?(RDF::Literal::DateTime)
        "RDF::Literal::DateTime(#{term.to_s.inspect})"
      else term.inspect
    end
    else term.inspect
  end
end

class RDF::Query
  # Equivalence for Queries:
  #   Same Patterns
  #   Same Context
  def ==(other)
    other.is_a?(RDF::Query) && patterns == other.patterns && context == context
  end

  def inspect
    "RDF::Query(#{context ? context.to_sxp : 'nil'})#{patterns.inspect}"
  end
end

class Array
  alias_method :old_inspect, :inspect

  def inspect
    if all? { |item| item.is_a?(Hash) }
      string = "[\n"
      each do |item|
        string += "  {\n"
          item.keys.map(&:to_s).sort.each do |key|
            string += "      #{key}: #{item[key.to_sym].inspect}\n"
          end
        string += "  },\n"
      end
      string += "]"
      string
    else
      old_inspect
    end
  end
end

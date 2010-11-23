require 'sparql/algebra'
require 'rdf/spec'

Spec::Runner.configure do |config|
  config.include(RDF::Spec::Matchers)
end

begin
  require 'sxp' # @see http://rubygems.org/gems/sxp
rescue LoadError
  abort "SPARQL::Algebra specs require the SXP gem (hint: `gem install sxp')."
end

def load_sse_examples(filename)
  input = File.read(File.join(File.dirname(__FILE__), filename))
  input.gsub!('-INF', "\"-INF\"^^<#{RDF::XSD.double}>") # FIXME in SXP.rb
  input.gsub!('+INF', "\"INF\"^^<#{RDF::XSD.double}>")  # FIXME in SXP.rb
  input.gsub!('NaN',  "\"NaN\"^^<#{RDF::XSD.double}>")  # FIXME in SXP.rb
  datatypes = {
    'xsd:double'   => RDF::XSD.double,
    'xsd:float'    => RDF::XSD.float,
    'xsd:integer'  => RDF::XSD.integer,
    'xsd:decimal'  => RDF::XSD.decimal,
    'xsd:string'   => RDF::XSD.string,
    'xsd:boolean'  => RDF::XSD.boolean,
    'xsd:dateTime' => RDF::XSD.dateTime,
  }
  datatypes.each { |qname, uri| input.gsub!(qname, "<#{uri}>") } # FIXME in SXP.rb
  examples = SXP::Reader::SPARQL.read_all(input)
  examples.inject({}) do |result, (tag, input, output)|
    output = case output
      when :ZeroDivisionError then ZeroDivisionError
      else output
    end
    result.merge(input => output)
  end
end

def repr(term)
  case term
    when RDF::Literal::Boolean
      "RDF::Literal::#{term.true? ? 'TRUE' : 'FALSE'}"
    when RDF::Literal::Numeric
      value = case term
        when RDF::Literal::Double  then term.to_f.inspect
        when RDF::Literal::Decimal then "BigDecimal(#{term.to_f.inspect})"
        when RDF::Literal::Integer then term.to_i.inspect
      end
      "RDF::Literal(#{value})"
    when RDF::Literal::DateTime
      "RDF::Literal::DateTime(#{term.to_s.inspect})"
    when RDF::Literal then case
      when term.datatype.eql?(RDF::XSD.string)
        "RDF::Literal::String(#{term.to_s.inspect})"
      when term.simple?
        "RDF::Literal(#{term.to_s.inspect})"
      else term.inspect
    end
    when RDF::Node
      "RDF::Node(#{term.to_sym.inspect})"
    when RDF::URI
      "RDF::URI(#{term.to_s.inspect})"
    else term.inspect
  end
end

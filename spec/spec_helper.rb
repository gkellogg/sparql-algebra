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

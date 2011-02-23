require "bundler/setup"
require 'sparql/algebra'
require 'rdf/spec'
require 'rdf/n3'
Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.include(RDF::Spec::Matchers)
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.exclusion_filter = {
    :ruby           => lambda { |version| RUBY_VERSION.to_s !~ /^#{version}/},
    :blank_nodes    => 'unique',
    :arithmetic     => 'native',
    :sparql_algebra => false,
    :status         => 'bug',
    :reduced        => 'all',
  }
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

# This file defines the sparql query function, which makes a sparql query and returns results.

# run a sparql query against SPARQL S-Expression (SSE)
# Options:
#   :graphs
#     example
#       opts[:graphs] ==
#        { :default => {
#             :data => '...',
#             :format => :ttl
#           },
#           <g1> => {
#            :data => '...',
#            :format => :ttl
#           }
#        }
#   :allow_empty => true
#     allow no data for query (raises an exception by default)
#   :query
#     A SSE query, as a string
#   :repository
#     The dydra repository associated with the account to use
#   :ssf
#     An SSF query, as a string #TODO
#   :form
#     :ask, :construct, :select or :describe
def sparql_query(opts)
  raise "Cannot run query without data" if (opts[:graphs].nil? || opts[:graphs].empty?) && !opts[:allow_empty]
  raise "A query is required to be run" if opts[:query].nil?

  # Load default and named graphs into repository
  repo = RDF::Repository.new do |r|
    opts[:graphs].each do |key, info|
      data, format = info[:data], info[:format]
      RDF::Reader.for(:file_extension => format).new(data).each_statement do |st|
        st.context = key unless key == :default
        r << st
      end
    end
  end

  begin
    query = SPARQL::Algebra::Expression.parse(opts[:query], :debug => ENV['PARSER_DEBUG'])
  #rescue Exception => e
  #  raise "Failed to parse SSE #{opts[:query]}: #{e.message}"
  end
  if opts[:query] =~ /\(leftjoin/
    pending ("leftjoin not implemented")
  elsif opts[:query] =~ /\(ask/
    pending ("ask not implemented")
  elsif opts[:query] =~ /\(describe/
    pending ("describe not implemented")
  elsif opts[:query] =~ /\(construct/
    pending ("construct not implemented")
  elsif opts[:query] =~ /\(graph/
    pending ("graph not implemented")
  else
    query.execute(repo, :debug => ENV['EXEC_DEBUG']).to_a.map(&:to_hash)
  end
end

# coding: utf-8
#
require 'spec_helper'

# Auto-generated by build_w3c_tests.rb
#
# normalization-02
# Example 1 from http://lists.w3.org/Archives/Public/public-rdf-dawg/2005JulSep/0096
# /Users/ben/repos/datagraph/tests/tests/data-r2/i18n/normalization-02.rq
#
# This is a W3C test from the DAWG test suite:
# http://www.w3.org/2001/sw/DataAccess/tests/r2#normalization-2
#
# This test is approved: 
# http://lists.w3.org/Archives/Public/public-rdf-dawg/2007JulSep/att-0047/31-dawg-minutes
#
# 20101218 jaa : bug indicator : the puri package does alot of un/escaping and normalization.
#  can be patched to disable, but ultimately, the iri should be opaque
# 20101216 jaa : modified prui to round-trip the original namestring

describe "W3C test" do
  context "i18n" do
    before :all do
      @data = %q{
# Example 1 from
# http://lists.w3.org/Archives/Public/public-rdf-dawg/2005JulSep/0096
# $Id: normalization-02.ttl,v 1.1 2005/08/09 14:35:26 eric Exp $
@prefix : <http://example/vocab#>.

:s1 :p <example://a/b/c/%7Bfoo%7D#xyz>.
:s2 :p <eXAMPLE://a/./b/../b/%63/%7bfoo%7d#xyz>.


}
      @query = %q{
        (prefix ((: <http://example/vocab#>)
                 (p1: <eXAMPLE://a/./b/../b/%63/%7bfoo%7d#>))
          (project (?S)
            (bgp (triple ?S :p p1:xyz))))
}
    end

    example "normalization-02" do
    
      graphs = {}
      graphs[:default] = { :data => @data, :format => :ttl}


      repository = 'i18n-normalization-2'
      expected = [
          { 
              :S => RDF::URI('http://example/vocab#s2'),
          },
      ]

      pending("Addressable normalizes when joining URIs") do
        sparql_query(:graphs => graphs, :query => @query,       # unordered comparison in rspec is =~
                     :repository => repository, :form => :select).should =~ expected
      end
    end
  end
end

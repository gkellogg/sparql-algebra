SPARQL Algebra for RDF.rb
=========================

This is an in-the-works (currently pre-alpha) [Ruby][] implementation of the
[SPARQL][] algebra for [RDF.rb][].

* <http://github.com/gkellogg/sparql-algebra>

Features
--------

* Implements all [SPARQL 1.0][] algebra operators generating `RDF::Query` compatible
  solution sequences.
* Implements `FILTER` expression optimizations such as constant folding,
  strength reduction, and memoization.
* Compatible with Ruby 1.8.7+, Ruby 1.9.x, and JRuby 1.4/1.5.
* 100% free and unencumbered [public domain](http://unlicense.org/) software.

Examples
--------

    require 'sparql/algebra'
    
    include SPARQL::Algebra

### Constructing operator expressions manually

    Operator(:isBlank).new(RDF::Node(:foobar))
    Operator(:isIRI).new(RDF::URI('http://rdf.rubyforge.org/'))
    Operator(:isLiteral).new(RDF::Literal(3.1415))
    Operator(:str).new(Operator(:datatype).new(RDF::Literal(3.1415)))

### Constructing operator expressions using SSE forms

    Expression[:isBlank, RDF::Node(:foobar)]
    Expression[:isIRI, RDF::URI('http://rdf.rubyforge.org/')]
    Expression[:isLiteral, RDF::Literal(3.1415)]
    Expression[:str, [:datatype, RDF::Literal(3.1415)]]

### Constructing operator expressions using SSE strings

    Expression.parse('(isBlank _:foobar)')
    Expression.parse('(isIRI <http://rdf.rubyforge.org/>)')
    Expression.parse('(isLiteral 3.1415)')
    Expression.parse('(str (datatype 3.1415))')

### Evaluating operators standalone

    Operator(:isBlank).evaluate(RDF::Node(:foobar))              #=> RDF::Literal::TRUE
    Operator(:isIRI).evaluate(RDF::DC.title)                     #=> RDF::Literal::TRUE
    Operator(:isLiteral).evaluate(RDF::Literal(3.1415))          #=> RDF::Literal::TRUE

### Evaluating expressions on a solution sequence

    require 'rdf/triples'
    
    # Find all people and their names & e-mail addresses:
    solutions = RDF::Query.execute(RDF::Graph.load('etc/doap.nt')) do |query|
      query.pattern [:person, RDF.type,  FOAF.Person]
      query.pattern [:person, FOAF.name, :name]
      query.pattern [:person, FOAF.mbox, :email], :optional => true
    end
    
    # Find people who have a name but don't have a known e-mail address:
    expression = Expression[:not, [:bound, Variable(:email)]]    # ...or just...
    expression = Expression.parse('(not (bound ?email))')
    solutions.filter!(expression)

### Optimizing expressions containing constant subexpressions

    Expression.parse('(sameTerm ?var ?var)').optimize            #=> RDF::Literal::TRUE
    Expression.parse('(* -2 (- (* (+ 1 2) (+ 3 4))))').optimize  #=> RDF::Literal(42)

Optimizations
-------------

Some very simple optimizations are currently implemented for `FILTER`
expressions. Use the following to obtain optimized SSE forms:

    Expression.parse(sse).optimize.to_sse

### Constant comparison folding

    (sameTerm ?x ?x)   #=> true

### Constant arithmetic folding

    (!= ?x (+ 123))    #=> (!= ?x 123)
    (!= ?x (- -1.0))   #=> (!= ?x 1.0)
    (!= ?x (+ 1 2))    #=> (!= ?x 3)
    (!= ?x (- 4 5))    #=> (!= ?x -1)
    (!= ?x (* 6 7))    #=> (!= ?x 42)
    (!= ?x (/ 0 0.0))  #=> (!= ?x NaN)

### Memoization

Expressions can optionally be [memoized][memoization], which can speed up
repeatedly executing the expression on a solution sequence:

    Expression.parse(sse, :memoize => true)
    Operator.new(*operands, :memoize => true)

Memoization is implemented using RDF.rb's [RDF::Util::Cache][] utility
library, a weak-reference cache that allows values contained in the cache to
be garbage collected. This allows the cache to dynamically adjust to
changing memory conditions, caching more objects when memory is plentiful,
but evicting most objects if memory pressure increases to the point of
scarcity.

[memoization]:      http://en.wikipedia.org/wiki/Memoization
[RDF::Util::Cache]: http://rdf.rubyforge.org/RDF/Util/Cache.html

Documentation
-------------

<http://sparql.rubyforge.org/algebra/>

* {SPARQL::Algebra}
  * {SPARQL::Algebra::Expression}
  * {SPARQL::Algebra::Query}
  * {SPARQL::Algebra::Operator}
    * {SPARQL::Algebra::Operator::Add}
    * {SPARQL::Algebra::Operator::And}
    * {SPARQL::Algebra::Operator::Asc}
    * {SPARQL::Algebra::Operator::Ask}
    * {SPARQL::Algebra::Operator::Base}
    * {SPARQL::Algebra::Operator::Bound}
    * {SPARQL::Algebra::Operator::Compare}
    * {SPARQL::Algebra::Operator::Construct}
    * {SPARQL::Algebra::Operator::Dataset}
    * {SPARQL::Algebra::Operator::Datatype}
    * {SPARQL::Algebra::Operator::Desc}
    * {SPARQL::Algebra::Operator::Distinct}
    * {SPARQL::Algebra::Operator::Divide}
    * {SPARQL::Algebra::Operator::Equal}
    * {SPARQL::Algebra::Operator::Exprlist}
    * {SPARQL::Algebra::Operator::Filter}
    * {SPARQL::Algebra::Operator::Graph}
    * {SPARQL::Algebra::Operator::GreaterThan}
    * {SPARQL::Algebra::Operator::GreaterThanOrEqual}
    * {SPARQL::Algebra::Operator::IsBlank}
    * {SPARQL::Algebra::Operator::IsIRI}
    * {SPARQL::Algebra::Operator::IsLiteral}
    * {SPARQL::Algebra::Operator::Join}
    * {SPARQL::Algebra::Operator::Lang}
    * {SPARQL::Algebra::Operator::LangMatches}
    * {SPARQL::Algebra::Operator::LeftJoin}
    * {SPARQL::Algebra::Operator::LessThan}
    * {SPARQL::Algebra::Operator::LessThanOrEqual}
    * {SPARQL::Algebra::Operator::Minus}
    * {SPARQL::Algebra::Operator::Multiply}
    * {SPARQL::Algebra::Operator::Not}
    * {SPARQL::Algebra::Operator::NotEqual}
    * {SPARQL::Algebra::Operator::Or}
    * {SPARQL::Algebra::Operator::Order}
    * {SPARQL::Algebra::Operator::Plus}
    * {SPARQL::Algebra::Operator::Prefix}
    * {SPARQL::Algebra::Operator::Project}
    * {SPARQL::Algebra::Operator::Reduced}
    * {SPARQL::Algebra::Operator::Regex}
    * {SPARQL::Algebra::Operator::SameTerm}
    * {SPARQL::Algebra::Operator::Slice}
    * {SPARQL::Algebra::Operator::Str}
    * {SPARQL::Algebra::Operator::Subtract}
    * {SPARQL::Algebra::Operator::Union}

Dependencies
------------

* [Ruby](http://ruby-lang.org/) (>= 1.8.7) or (>= 1.8.1 with [Backports][])
* [RDF.rb](http://rubygems.org/gems/rdf) (>= 0.3.1)
* [SXP](http://rubygems.org/gems/sxp) (>= 0.0.14) for [SSE][] parsing only

Installation
------------

The recommended installation method is via [RubyGems](http://rubygems.org/).
To install the latest official release of the `SPARQL::Algebra` gem, do:

    % [sudo] gem install sparql-algebra

Download
--------

To get a local working copy of the development repository, do:

    % git clone git://github.com/bendiken/sparql-algebra.git

Alternatively, download the latest development version as a tarball as
follows:

    % wget http://github.com/bendiken/sparql-algebra/tarball/master

Mailing List
------------

* <http://lists.w3.org/Archives/Public/public-rdf-ruby/>

Authors
------

* [Arto Bendiken](http://github.com/bendiken) - <http://ar.to/>
* [Gregg Kellogg](http://github.com/gkellogg) - <http://kellogg-assoc.com/>

Contributors
------------

Refer to the accompanying {file:CREDITS} file.

Contributing
------------

* Do your best to adhere to the existing coding conventions and idioms.
* Don't use hard tabs, and don't leave trailing whitespace on any line.
* Do document every method you add using [YARD][] annotations. Read the
  [tutorial][YARD-GS] or just look at the existing code for examples.
* Don't touch the `.gemspec`, `VERSION` or `AUTHORS` files. If you need to
  change them, do so on your private branch only.
* Do feel free to add yourself to the `CREDITS` file and the corresponding
  list in the the `README`. Alphabetical order applies.
* Do note that in order for us to merge any non-trivial changes (as a rule
  of thumb, additions larger than about 15 lines of code), we need an
  explicit [public domain dedication][PDD] on record from you.

License
-------

This is free and unencumbered public domain software. For more information,
see <http://unlicense.org/> or the accompanying {file:UNLICENSE} file.

Portions of tests are derived from [W3C DAWG tests](http://www.w3.org/2001/sw/DataAccess/tests/) and have [other licensing terms](http://www.w3.org/2001/sw/DataAccess/tests/data-r2/LICENSE).

[Ruby]:       http://ruby-lang.org/
[RDF]:        http://www.w3.org/RDF/
[SPARQL]:     http://en.wikipedia.org/wiki/SPARQL
[SPARQL 1.0]: http://www.w3.org/TR/rdf-sparql-query/
[SPARQL 1.1]: http://www.w3.org/TR/sparql11-query/
[algebra]:    http://www.w3.org/TR/rdf-sparql-query/#sparqlAlgebra
[EBV]:        http://www.w3.org/TR/rdf-sparql-query/#ebv
[SSE]:        http://openjena.org/wiki/SSE
[RDF.rb]:     http://rdf.rubyforge.org/
[YARD]:       http://yardoc.org/
[YARD-GS]:    http://rubydoc.info/docs/yard/file/docs/GettingStarted.md
[PDD]:        http://unlicense.org/#unlicensing-contributions
[Backports]:  http://rubygems.org/gems/backports

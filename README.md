SPARQL Algebra for RDF.rb
=========================

This is a [Ruby][] implementation of the [SPARQL][] algebra for [RDF.rb][].
(Currently in pre-alpha state.)

* <http://github.com/bendiken/sparql-algebra>

Features
--------

* 100% free and unencumbered [public domain](http://unlicense.org/) software.
* Compatible with Ruby 1.8.7+, Ruby 1.9.x, and JRuby 1.4/1.5.

Examples
--------

    require 'rubygems'
    require 'sparql/algebra'

Documentation
-------------

<http://sparql.rubyforge.org/algebra/>

* {SPARQL::Algebra}

Dependencies
------------

* [Ruby](http://ruby-lang.org/) (>= 1.8.7) or (>= 1.8.1 with [Backports][])
* [RDF.rb](http://rubygems.org/gems/rdf) (>= 0.3.0)

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

Author
------

* [Arto Bendiken](http://github.com/bendiken) - <http://ar.to/>

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

[Ruby]:       http://ruby-lang.org/
[RDF]:        http://www.w3.org/RDF/
[SPARQL]:     http://en.wikipedia.org/wiki/SPARQL
[SPARQL 1.0]: http://www.w3.org/TR/rdf-sparql-query/
[SPARQL 1.1]: http://www.w3.org/TR/sparql11-query/
[algebra]:    http://www.w3.org/TR/rdf-sparql-query/#sparqlAlgebra
[RDF.rb]:     http://rdf.rubyforge.org/
[YARD]:       http://yardoc.org/
[YARD-GS]:    http://rubydoc.info/docs/yard/file/docs/GettingStarted.md
[PDD]:        http://unlicense.org/#unlicensing-contributions
[Backports]:  http://rubygems.org/gems/backports

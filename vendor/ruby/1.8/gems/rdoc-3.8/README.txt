= \RDoc - Ruby Documentation System

* {RDoc Project Page}[https://github.com/rdoc/rdoc/]
* {RDoc Documentation}[http://docs.seattlerb.org/rdoc]
* {RDoc Bug Tracker}[https://github.com/rdoc/rdoc/issues]

== DESCRIPTION:

RDoc produces HTML and command-line documentation for Ruby projects.  RDoc
includes the +rdoc+ and +ri+ tools for generating and displaying online
documentation.

See RDoc for a description of RDoc's markup and basic use.

== SYNOPSIS:

To learn RDoc's syntax and directives for documenting your ruby project see
RDoc::Markup.  RDoc::Parser::Ruby and RDoc::Parser::C have additional
directives (such as metaprogrammed methods) for documenting Ruby and C files
respectively.

To generate HTML documentation for your project run <tt>rdoc .</tt> in your
project's root directory.

To determine how well your project is documented run <tt>rdoc -C lib</tt> to
get a documentation coverage report.  <tt>rdoc -C1 lib</tt> includes parameter
names in the documentation coverage report.

To generate documentation using +rake+ see RDoc::Task.

To generate documentation programmatically:

  gem 'rdoc'
  require 'rdoc/rdoc'

  options = RDoc::Options.new
  # see RDoc::Options

  rdoc = RDoc::RDoc.new
  rdoc.document options
  # see RDoc::RDoc

== BUGS:

If you find a bug, please report it at the RDoc project's
{issues tracker}[https://github.com/rdoc/rdoc/issues] on github

== LICENSE:

RDoc is Copyright (c) 2001-2003 Dave Thomas, The Pragmatic Programmers.
Portions (c) 2007-2011 Eric Hodel.  Portions copyright others, see individual
files for details.

It is free software, and may be redistributed under the terms specified in
LICENSE.txt.

== WARRANTY:

This software is provided "as is" and without any express or implied
warranties, including, without limitation, the implied warranties of
merchantibility and fitness for a particular purpose.

# @title What's New?

# What's New in 0.7.x?

1. **Macro support and detection of DSL methods** (0.7.0)
2. **Inherited attributes now show in HTML output** (0.7.0)
3. **The 'app' directory is now parsed by default** (0.7.0)
4. **Added support for metadata (@title, @markup) in extra files/readmes** (0.7.0)
5. **Added `yard list` command (alias for `yardoc --list`)** (0.7.0)
6. **Added Git support in `yard diff`** (0.7.0)
7. **Added `{include:file:FILENAME}` syntax** (0.7.0)
8. **Added `{render:OBJECT}` syntax to embed object docs in extra files** (0.7.0)
9. **Added improved templates API for custom CSS/JS/menus** (0.7.0)
10. **Added Ruby markup type (`-m ruby`)** (0.7.0)
11. **Added state tracking variables to Parser/Handler architecture** (0.7.0)
12. **Added before/after callbacks to SourceParser** (0.7.0)
13. **Can now use `--yardopts FILE` to specify a custom yardopts file** (0.7.0)
14. **Added new `-t guide` template for guide based docs** (0.7.0)

## Macro support and detection of DSL methods (0.7.0)

YARD will now automatically detect class level method calls, similar to the
way it knows what an `attr_accessor` is. By simply adding documentation to
your class level declarations, YARD can automatically detect them as methods
or attributes in your class. Consider DataMapper's "property" declaration:

    class Post
      # @attribute
      # @return [String] the title of the post
      property :title, String
    end
    
The above declaration would be created as the `Post#title`. The optional
`@attribute` tag tells YARD that the property is an "attribute", and not just
a regular method.

In addition to basic DSL method detection, YARD also supports macros to create
docstrings that can be copies to other objects; these macros can also be 
"attached" to class level methods to create implicit documentation for macros.

Macros and DSL method detection are discussed in much more detail in the 
{file:docs/GettingStarted.md}, so you should read about them there if you're
interested in this feature.

## Inherited attributes now show in HTML output (0.7.0)

Inherited attributes will now show up in HTML documentation using the default
template in the same manner that inherited methods do.

## The 'app' directory is now parsed by default (0.7.0)

YARD tries to follow the "It Just Works" attitude in writing developer tools, 
and therefore has added `app/**/*.rb` to the default list of globs that it
searches for code in. You no longer need to create a `.yardopts` just to
list your app directory when documenting your code on rubydoc.info. 
We should have done this a while ago! And don't worry, YARD still checks
lib and ext by default, too.

## Added support for metadata (@title, @markup) in extra files/readmes (0.7.0)

Extra files (READMEs, ChangeLogs, LICENSE files, and other guides) now support
metadata tags, just like docstrings in code comments. By adding @tag values
to the top of a file (no whitespace preceding it) inside of a `# comment` line,
YARD will detect and parse these tags and store it for later usage. 

Tags can contain arbitrary data as well as arbitrary tag names, however the 
tag names @title and @markup are reserved to specify the document title and 
markup format respectively. The title will be used in the file list menu,
index page, as well as any linking of the file via the `{file:Filename}`
syntax. An example of a document with metadata would be:

    # @title The Best Project Ever!
    # @markup rdoc
    # @author Foo Bar (custom tag, does not display in templates)
    
    = This Project Rules
    
    == Contents
    
    ...

Note that previous versions of YARD recommended specifying the markup of an
extra file with the `#!markup` shebang, but the `@markup` metadata tag is now
the "best practice" for specifying the markup format of an extra file.

## Added `yard list` command (alias for `yardoc --list`) (0.7.0)

The `yardoc --list` command is used to list objects that are parsed from
a codebase. This can be used to grep methods/classes in a codebase from the
command line. `yard list` now calls `yardoc --list` as a convenience command.

Note that the `yardoc --list` command may eventually be replaced by a more 
feature-filled `yard list` command, so `yard list` should be used instead of
`yardoc --list` when possible.

## Added Git support in `yard diff` (0.7.0)

The `yard diff` command can now perform object diffing on git repositories.
Provide the `--git` switch to `yard diff` with 2 commit/branches like so:

    $ yard diff --git HEAD~5 HEAD
    Added objects:

      YARD::Parser::SourceParser#contents
      YARD::Parser::SourceParser#globals
      ...

## Added `{include:file:FILENAME}` syntax (0.7.0)

You can now use the `{include:file:FILENAME}` syntax to embed the contents
of an extra file marked up in its markup format. This syntax supports embedding
Ruby source files and performing syntax highlighting on the code.

## Added `{render:OBJECT}` syntax to embed object docs in extra files (0.7.0)

You can now use the `{render:Object}` syntax to embed the documentation 
rendering of an entire object (method, class, module) inside of an extra file.
This is useful when writing non-API based guides that might require listing
a few helper methods or classes. The {file:docs/GettingStarted.md} discussed
this syntax in more detail (with example usage).

## Added improved templates API for custom CSS/JS/menus (0.7.0)

Plugin & template developers can now more easily insert custom stylesheet
or JavaScript files in their customized templates, thanks to an abstraction
of the template API. This is documented in the {docs/Templates.md} document.
In addition to custom CSS/JS, developers can also create custom menu tabs
in both the framed and non framed version of the default theme.

## Added Ruby markup type (`-m ruby`) (0.7.0)

The Ruby markup type (`-m ruby`) will now use syntax highlighting for all
formatting. This is probably not useful as a global switch, but can be used
on individual extra files using the metadata markup specification discussed
above.

## Added state tracking variables to Parser/Handler architecture (0.7.0)

The parser and handler architecture now contain state variables 
{YARD::Handlers::Base#extra_state} and {YARD::Handlers::Processor#globals}
to share data across handlers and the entire processing phase. `#extra_state`
provided a place to store per-file data, while `#globals` gives the developer
access to inter-file state when parsing multiple files at once.

## Added before/after callbacks to SourceParser (0.7.0)

The {YARD::Parser::SourceParser} class can now register callbacks to execute
code before and after parsing of file globs, as well as before and after
parsing of individual files. This allows plugin developers to perform
setup/teardown (and set global state or update the {YARD::Registry}).

See the documentation for the following methods:

* {YARD::Parser::SourceParser.before_parse_list}
* {YARD::Parser::SourceParser.after_parse_list}
* {YARD::Parser::SourceParser.before_parse_file}
* {YARD::Parser::SourceParser.after_parse_file}

## Can now use `--yardopts FILE` to specify a custom yardopts file (0.7.0)

The `yardoc` command now supports `--yardopts FILE` to specify custom .yardopts
options files. This is useful if you have multiple documentation sets, such
as a guide documentation set and an API documentation set.

## Added new `-t guide` template for guide based docs (0.7.0)

You can now write guide style documentation using a new 'guide' template that
only generates documentation for extra files. You would use it in the form:

    yardoc -t guide - README GettingStarted FAQ TroubleShooting LICENSE

This creates the sections for the readme, a getting started, frequently asked
questions, trouble shooting and license page.

If you need to refer to class / method documentation, you can embed API documentation
using the `{render:Object}` tag discussed above.

# What's New in 0.6.x?

1. **Local documentation server for RubyGems or projects (`yard server`)** (0.6.0)
2. **Groups support for method listing** (0.6.0)
3. **Single file template (`--one-file`) support** (0.6.0)
4. **`yard` CLI executable with pluggable commands** (0.6.0)
5. **`yard diff` command to object-diff two versions of a project** (0.6.0)
6. **Added `--asset` option to `yardoc`** (0.6.0)
7. **New template API** (0.6.0)
8. **HTML template now adds inline Table of Contents for extra files pages** (0.6.0)
9. **Removed `--incremental` in favour of `--use-cache`** (0.6.0)
10. **Ad-hoc tag registration via `yardoc` CLI (`--tag`, etc.)** (0.6.0)
11. **Added `--transitive-tags` to register transitive tags** (0.6.0)
12. **`yardoc` now displays RDoc-like statistics (`--no-stats` to hide)** (0.6.0)
13. **`yri` now works on constants** (0.6.0)
14. **Plugins are no longer auto-loaded (added `--plugin` switch)** (0.6.2)
15. **Added `YARD::Config` API and `~/.yard/config` configuration file** (0.6.2)
16. **Added `yard config` command to view/edit configuration** (0.6.2)
17. **Added `yard server -t` template path switch** (0.6.2)
18. **Added `YARD::Server.register_static_path` for static server assets** (0.6.2)
19. **YARD::Registry is now thread local** (0.6.5)
20. **Support for ripper gem in Ruby 1.8.7** (0.6.5)

## Local documentation server for RubyGems or projects (`yard server`) (0.6.0)

The new `yard server` command spawns a documentation server that can serve
either documentation for a local project or installed RubyGems. The server 
will host (by default) on http://localhost:8808. 

To serve documentation for the active project (in the current directory):

    $ yard server
    
The server can also run in "incremental" mode for local projects. In this 
situation, any modified sources will immediately be updated at each request, 
ensuring that the server always serve the code exactly as it is on disk. 
Documenting your code in this fashion essentially gives you an efficient a 
live preview without running a separate command everytime you make a change. 
To serve documentation for the active project in incremental mode:

    $ yard server --reload
    
<span class="note">Note that in incremental mode, objects or method groupings 
  cannot be removed. If you have removed objects or modified groupings, you 
  will need to flush the cache by deleting `.yardoc` and (optionally) 
  restarting the server.</span>

The documentation server can also serve documentation for all installed gems 
on your system, similar to `gem server`, but using YARD's functionality and 
templates. To serve documentation for installed gems:

    $ yard server --gems
    
<span class="note">Documentation for the gem need not be previously generated 
  at install-time. If documentation for the gem has not been generated, YARD 
  will do this for you on-the-fly. It is therefore possible to speed up your 
  gem installs by using `gem install GEMNAME --no-rdoc` without repercussion.
  You can also add this switch to your `~/.gemrc` file so that you don't need
   to re-type it each time. See [this link](http://stackoverflow.com/questions/1789376/how-do-i-make-no-ri-no-rdoc-the-default-for-gem-install) 
   for exact instructions.</span>

## Groups support for method listing (0.6.0)

You can now organize methods in a class/module into logical separated groups. 
These groups apply lexically and are listed in the order they are defined. 
For instance, to define a group:

    # @group Rendering an Object
    
    # Documentation here
    def foo; end
    
    # Extra documentation...
    def bar; end
    
    # @group Another Group
    
    def aaa; end
    
<span class="note">Note that these `@group` and `@endgroup` declarations are 
  not "tags" and should always be separated with at least 1 line of whitespace 
  from any other documentation or code.</span>
    
In the above example, "Rendering an Object" will be listed with "foo" and 
"bar" above "Another Group", even though "aaa" comes before the two other 
methods, alphabetically. To end a group, use `@endgroup`. It is not necessary 
to end a group to start a new one, only if there is an object following the 
group that should not belong in any group.

    # @group Group 1
    
    def foo; end
    
    # @endgroup
    
    # This method should not be listed in any group
    def bar; end

## Single file template (`--one-file`) support (0.6.0)

`yardoc` now has the `--one-file` option to generate a single-file template 
for small scripts and libraries. In this case, any comments at the top of 
the script file will be recognized as a README.

## `yard` CLI executable with pluggable commands (0.6.0)

<span class="note">The `yardoc` and `yri` commands are not deprecated and can 
  continue to be used. They are shortcuts for `yard doc` and `yard ri` 
  respectively. However, `yard-graph` has been removed.</span>

YARD now has a `yard` executable which combines all pre-existing and new 
commands into a single pluggable command that is both easier to remember and 
access. To get a list of commands, type `yard --help`.

If you are a plugin developer, you can create your own `yard` command by first 
subclassing the {YARD::CLI::Command} class and then registering this class 
with the {YARD::CLI::CommandParser.commands} list. For instance:

    YARD::CLI::CommandParser.commands[:my_command] = MyCommandClass
    
The above line will enable the user to execute `yard my_command [options]`.

## `yard diff` command to object-diff two versions of a project (0.6.0)

One of the built-in commands that comes with the new `yard` executable is the 
ability to do object-oriented diffing across multiple versions of the same 
project, either by 2 versions of a gem, or 2 working copies. Just like 
regular diffing tells you which lines have been added/removed in a file, 
object diffing allows you to see what classes/methods/modules have been 
added/removed between versions of a codebase.

For an overview of how to use `yard diff`, see [YARD Object Oriented Diffing](http://gnuu.org/2010/06/26/yard-object-oriented-diffing/).

## `yard stats` to display statistics and undocumented objects (0.6.0)

YARD now outputs the following statistics when `yard stats` is run:

    Files:         125
    Modules:        35 (    4 undocumented)
    Classes:       139 (   29 undocumented)
    Constants:      53 (   20 undocumented)
    Methods:       602 (   70 undocumented)
     85.16% documented
    
Note that these statistics are based on what you have set to show in your 
documentation. If you use `@private` tags and/or do not display 
private/protected methods in your documentation, these will not show up as 
undocumented. Therefore this metric is contextual.

You can also specifically list all undocumented objects (and their file 
locations) with the `--list-undoc` option.

## Added `--asset` option to `yardoc` (0.6.0)

The `yardoc` command can now take the `--asset` option to copy over 
files/directories (recursively) to the output path after generating 
documentation. The format of the argument is "from:to" where from is the 
source path and to is the destination. For instance, YARD uses the following 
syntax in the `.yardopts` file to copy over image assets from the 
'docs/images' directory into the 'images' directory after generating HTML:

    --asset docs/images:images

## New template API (0.6.0)

The new template API allows for easier insertion of sections within an 
inherited template. You should no longer need to insert by index, an 
error-prone process that could break when a template is updated. Instead of:

    sections.last.place(:my_section).before(:another_section)

use:

    sections.place(:my_section).before_any(:another_section)
    
You can see more in the {file:docs/Templates.md#Inserting_and_Traversing_Sections}
document.

## HTML template now adds inline Table of Contents for extra files pages (0.6.0)

A table of contents is now generated dynamically using JavaScript for extra 
file pages (such as README's, or this document). It is generated based off the
headers (h1,h2,... tags) used in the document, and can be floated to the 
right or listed inline on the page.

## Ad-hoc tag registration via `yardoc` CLI (`--tag`, etc.) (0.6.0)

Simple meta-data tags can now be added at the command-line and registered to 
display in templates in a number of pre-defined ways. For instance, to create 
a freeform text tag, use the following:

    --tag my_tag_name:"My Tag Title"
    
You can also create a "typed" tag (similar to `@return`), a typed named tag 
(similar to `@param`) as well as various combinations. The full list of 
options are listed in `yardoc --help` under the "Tag Options" section.
    
If you wish to create a tag to store data but do not wish to show this data 
in the templates, use the `--hide-tag` option to hide it from generated output:

    --hide-tag my_tag_name

## Added `--transitive-tags` to register transitive tags (0.6.0)

Transitive tags are tags that apply to all descendants of a namespace (class 
or module) when documented on that namespace. For instance, the `@since` tag 
is a transitive tag. Applying `@since` to a class will automatically apply 
`@since` to all methods in the class. Creating a `@since` tag directly on a 
method will override the inherited value.

You can specify transitive tags on the command-line by using this option. Note
that the tags must already exist (built-in or created with the `--tag` option)
to be specified as transitive. If you wish to do this programmatically, see 
the {YARD::Tags::Library.transitive_tags} attribute.

## `yardoc` now displays RDoc-like statistics (`--no-stats` to hide) (0.6.0)

As seen in the `yard stats` feature overview, `yardoc` displays RDoc-like 
statistics when it is run. The output is equivalent to typing `yard stats`. 
To hide this output when yardoc is run, use `--no-stats`.

## `yri` now works on constants (0.6.0)

Templates have now been added for text view of constants, which displays any 
documentation and the constant value.

## Plugins are no longer auto-loaded (added `--plugin` switch) (0.6.2)

This is a backwards-incompatible change that disables plugins from automatically
loading when YARD starts up. From now on, you should manually declare which
plugins your project is using by adding `--plugin PLUGINNAME` to a `.yardopts`
file in the root of your project. You can also re-enable autoloaded plugins
by setting `load_plugins` to true in your configuration file (`yard config load_plugins true`, 
see next item). You can also set `autoload_plugins` to a list of plugins 
to be automatically loaded on start.

If you are a YARD plugin author, please make sure to inform your users of these
changes.

Note that `--plugin` switches passed on the commandline (not via `.yardopts`) 
are parsed before commands are loaded, and therefore can add in new CLI commands.

## Added `YARD::Config` API and `~/.yard/config` configuration file (0.6.2)

There is a new global configuration API that can be accessed programmatically
and set via the `~/.yard/config` file. The file is encoded as a YAML file,
and looks like:

    :load_plugins: false
    :ignored_plugins:
      - my_plugin
      - my_other_plugin
    :autoload_plugins:
      - my_autoload_plugin
    :safe_mode: false

You can also set configuration options via the command-line (see next item).
    
## Added `yard config` command to view/edit configuration (0.6.2)

A new `yard config` command was created to view or edit the configuration
file via the commandline. 

* To view the current configuration use `yard config --list`.
* To view a specific item use `yard config ITEMNAME`
* To modify an item value use `yard config ITEMNAME VALUE`

## Added `yard server -t` template path switch (0.6.2)

The `yard server` command now accepts `-t` or `--template-path` to register
a new template path for template customization.

## Added `YARD::Server.register_static_path` for static server assets (0.6.2)

The server now supports a command to register static asset paths. If you are
extending the YARD::Server modules, make sure to register your asset paths
through this method.

## YARD::Registry is now thread local (0.6.5)

Creating a new thread will now implicitly load a new Registry that can be used
to parse and process new code objects independently of the other threads. Note
that this means you can no longer use the Registry across threads; you must
either access the threadlocal object directly, or synchronize threads to do
the processing in the initial registry's thread.

## Support for ripper gem in Ruby 1.8.7 (0.6.5)

YARD now supports the Ruby 1.8.7 port of the `ripper` gem to improve parsing
of source, both in terms of performance and functionality. When the `ripper`
gem is available, YARD will use the "new-style" handlers. You can take advantage
of this functionality by performing a `gem install ripper`.


What's New in 0.5.x?
====================

1. **Support for documenting native Ruby C code** (0.5.0)
2. **Incremental parsing and output generation with `yardoc -c`** (0.5.0, 0.5.3)
2. **Improved `yri` support to perform lookups on installed Gems** (0.5.0)
3. **Added `yardoc --default-return` and `yardoc --hide-void-return`** (0.5.0)
4. **Multiple syntax highlighting language support** (0.5.0)
5. **New .yardoc format** (0.5.0)
6. **Support for yard-doc-* gem packages as hosted .yardoc dbs** (0.5.1)
7. **Support for extra search paths in `yri`** (0.5.1)
8. **Generating HTML docs now adds frames view** (0.5.3)
9. **Tree view for class list** (0.5.3)
10. **Ability to specify markup format of extra files** (0.5.3)
11. **Keyboard shortcuts for default HTML template** (0.5.4)

Support for documenting native Ruby C code (0.5.0)
--------------------------------------------------

It is now possible to document native Ruby extensions with YARD with a new
C parser mostly borrowed from RDoc. This enables the ability to document
Ruby's core and stdlibs which will be hosted on http://yardoc.org/docs. In
addition, the .yardoc dump for the Ruby-core classes will become available
as an installable gem for yri support (see #3).

Incremental parsing and output generation with `yardoc -c` (0.5.0, 0.5.3)
-------------------------------------------------------------------------

<p class="note">Note: in 0.5.3 and above you must use <tt>--incremental</tt> 
  to incrementally generate HTML, otherwise only parsing will be done 
  incrementally but HTML will be generated with all objects. <tt>--incremental</tt>
  implies <tt>-c</tt>, so no need to specify them both.</p>

YARD now compares file checksums before parsing when using `yardoc -c`
(aka `yardoc --use-cache`) to do incremental parsing of only the files that
have changed. HTML (or other output format) generation will also only be
done on the objects that were parsed from changed files (\*). This makes doing
a documentation development cycle much faster for quick HTML previews. Just
remember that when using incremental output generation, the index will not
be rebuilt and inter-file links might not hook up right, so it is best to
perform a full rebuild at the end of such previews.

(\*) Only for versions prior to 0.5.3. For 0.5.3+, use `--incremental` for
incremental HTML output.

Improved `yri` support to perform lookups on installed Gems (0.5.0)
-------------------------------------------------------------------

The `yri` executable can now perform lookups on gems that have been parsed
by yard. Therefore, to use this command you must first parse all gems with
YARD. To parse all gems, use the following command:

    $ sudo yardoc --build-gems
    
The above command builds a .yardoc file for all installed gems in the
respective gem directory. If you do not have write access to the gem path,
YARD will write the yardoc file to `~/.yard/gem_index/NAME-VERSION.yardoc`.

Note: you can also use `--re-build-gems` to force re-parsing of all gems.

You can now do lookups with yri:

    $ yri JSON
    
All lookups are cached to `~/.yard/yri_cache` for quicker lookups the second
time onward.

Added `yardoc --default-return` and `yardoc --hide-void-return` (0.5.0)
-----------------------------------------------------------------------

YARD defaults to displaying (Object) as the default return type of any
method that has not declared a @return tag. To customize the default
return type, you can specify:

    $ yardoc --default-return 'MyDefaultType'
    
You can also use the empty string to list no return type.

In addition, you can use --hide-void-return to ignore any method that
defines itself as a void type by: `@return [void]`

Multiple syntax highlighting language support (0.5.0)
-----------------------------------------------------

YARD now supports the ability to specify a language type for code blocks in 
docstrings. Although no actual highlighting support is added for any language
but Ruby, you can add your own support by writing your own helper method:

    # Where LANGNAME is the language:
    def html_syntax_highlight_LANGNAME(source)
      # return highlighted HTML
    end
    
To use this language in code blocks, prefix the block with `!!!LANGNAME`:

    !!!plain
    !!!python
    def python_code(self):
      return self

By the same token. you can now use `!!!plain` to ignore highlighting for
a specific code block.

New .yardoc format (0.5.0)
--------------------------

To make the above yri support possible, the .yardoc format was redesigned
to be a directory instead of a file. YARD can still load old .yardoc files,
but they will be automatically upgraded if re-saved. The new .yardoc format
does have a larger memory footprint, but this will hopefully be optimized
downward.

Support for yard-doc-* gem packages as hosted .yardoc dbs (0.5.1)
-----------------------------------------------------------------

You can now install special YARD plugin gems titled yard-doc-NAME to get
packaged a .yardoc database. This will enable yri lookups or building docs
for the gem without the code. 

One main use for this is the `yard-doc-core` package, which enabled yri 
support for Ruby core classes (stdlib coming soon as `yard-doc-stdlib`).
To install it, simply:

    $ sudo gem install yard-doc-core
    # now you can use:
    $ yri String

This will by default install the 1.9.1 core library. To install a library
for a specific version of Ruby, use the `--version` switch on gem:

    $ sudo gem install --version '= 1.8.6' yard-doc-core

Support for extra search paths in `yri` (0.5.1)
-----------------------------------------------

You can now add custom paths to non-gem .yardoc files 
by adding them as newline separated paths in `~/.yard/yri_search_paths`.

Generating HTML docs now adds frames view (0.5.3)
-------------------------------------------------

`yardoc` will now create a `frames.html` file when generating HTML documents
which allows the user to view documentation inside frames, for those users who
still find frames beneficial.

Tree view for class list (0.5.3)
--------------------------------

The class list now displays as an expandable tree view to better organized an 
otherwise cluttered namespace. If you properly namespace your less important
classes (like Rails timezone classes), they will not take up space in the
class list unless the user looks for them.

Ability to specify markup format of extra files (0.5.3)
-------------------------------------------------------

You can now specify the markup format of an extra file (like README) at the
top of the file with a shebang-like line:

    #!textile
    contents here
    
The above file contents will be rendered with a textile markup engine 
(eg. RedCloth).

Keyboard shortcuts for default HTML template (0.5.4)
----------------------------------------------------

You can now access the "Class List", "Method List" and "File List" with the
'c', 'm' and 'f' keyboard shortcuts in the default HTML template, allowing
for keyboard-only navigation around YARD documentation.

API for registering custom parsers (0.5.6)
------------------------------------------

You can now register parsers for custom source languages by calling the
following method:

    SourceParser.register_parser_type(:java, MyJavaParser, 'java')
    
The parser class MyJavaParser should be a subclass of {YARD::Parser::Base},
and the last argument is a set of extensions (string, array or regexp). You
can read more about registering parsers at the {YARD::Parser::SourceParser}
class documentation.


What's New in 0.4.x?
====================

1. **New templating engine and templates**
2. **yardoc `--query` argument**
3. **Greatly expanded API documentation**
4. **New plugin support**
5. **New tags (@abstract, @private)**
6. **Default rake task is now `rake yard`**

New templating engine and templates
-----------------------------------

The templates were redesigned, most notably removing the ugly frameset, adding
search to the class/method lists, simplifying the layout and making things 
generally prettier. You should also notice that more tags are now visible in
the templates such as @todo, the new @abstract and @note tags and some others
that existed but were previously omitted from the generated documentation.

There is also a new templating engine (based on the tadpole templating library) 
to allow for much more user customization. You can read about it in 
{file:docs/Templates.md}.

yardoc `--query` argument
-------------------------

The yardoc command-line tool now supports queries to select which classes,
modules or methods to include in documentation based on their data or meta-data.
For instance, you can now generate documentation for your "public" API only by
adding "@api public" to each of your public API methods/classes and using
the following argument:

    --query '@api.text == "public"'
    
More information on queries is in the {file:README.md}.

Greatly expanded API documentation
----------------------------------

Last release focused on many how-to and architecture documents to explain
the design of YARD, but many of the actual API classes/methods were still
left undocumented. This release marks a focus on getting YARD's own documentation
up to par so that it can serve as an official reference on the recommended
conventions to use when documenting code.

New plugin support
------------------

YARD now supports loading of plugins via RubyGems. Any gem named `yard-*` or
`yard_*` will now be loaded when YARD starts up. Note that the '-' separator 
is the recommended naming scheme.

To ignore plugins, add the gem names to `~/.yard/ignored_plugins` on separate
lines (or separated by whitespace).

New tags (@abstract, @private)
------------------------------

Two new tags were added to the list of builtin meta-tags in YARD. `@abstract`
marks a class/module/method as abstract while `@private` marks an object
as "private". The latter tag is unsed in situations where an object is public
due to Ruby's own visibility limitations (constants, classes and modules
can never be private) but not actually part of your public API. You should
use this tag sparingly, as it is not meant to be an equivalent to RDoc's
`:nodoc:` tag. Remember, YARD recommends documenting private objects too.
This tag exists so that you can create a query (`--query !@private`) to
ignore all of these private objects in your documentation. You can also
use the new `--no-private` switch, which is a shortcut to the afformentioned
query. You can read more about the new tags in the {file:docs/GettingStarted.md} 
guide.

Default rake task is now `rake yard`
------------------------------------

Not a big change, but anyone using the default "rake yardoc" task should
update their scripts: 

[http://github.com/lsegal/yard/commit/ad38a68dd73898b06bd5d0a1912b7d815878fae0](http://github.com/lsegal/yard/commit/ad38a68dd73898b06bd5d0a1912b7d815878fae0)


What's New in 0.2.3.x?
======================

1. **Full Ruby 1.9 support**
2. **New parser code and handler API for 1.9**
3. **A new `@overload` tag**
4. **Better documentation**
5. **Template changes and bug fixes**

Full Ruby 1.9 support
---------------------

YARD's development actually focuses primarily on 1.9 from the get-go, so it is 
not an afterthought. All features are first implemented for compatibility with 
1.9, but of course all functionality is also tested in 1.8.x. YARD 0.2.2 was
mostly compatible with 1.9, but the new release improves and extends in certain
areas where compatibility was lacking. The new release should be fully functional
in Ruby 1.9.
  
New parser code and handler API for 1.9
---------------------------------------

Using Ruby 1.9 also gives YARD the advantage of using the new `ripper` library 
which was added to stdlib. The ripper parser is Ruby's official answer to 
projects like ParseTree and ruby2ruby. Ripper allows access to the AST as it 
is parsed by the Ruby compiler. This has some large benefits over alternative 
projects: 

  1. It is officially supported and maintained by the Ruby core team.
  2. The AST is generated directly from the exact same code that drives the
     compiler, meaning anything that compiles is guaranteed to generate the
     equivalent AST.
  3. It needs no hacks, gems or extra libs and works out of the box in 1.9.
  4. It's *fast*.
  
Having the AST means that developers looking to extend YARD have much better
access to the parsed code than in previous versions. The only caveat is that
this library is not back-compatible to 1.8.x. Because of this, there are
subtle changes to the handler extension API that developers use to extend YARD.
Namely, there is now a standard API for 1.9 and a "legacy" API that can run in
both 1.8.x and 1.9 if needed. A developer can still use the legacy API to write
handlers that are compatible for both 1.8.x and 1.9 in one shot, or decide to
implement the handler using both APIs. Realize that the benefit of using the new
API means 1.9 users will get a 2.5x parsing speed increase over running the legacy
handlers (this is *in addition to* the ~1.8x speed increase of using YARV over MRI).
    
A new `@overload` tag
---------------------

The new `@overload` tag enables users to document methods that take multiple 
parameters depending on context. This is basically equivalent to RDoc's call-seq,
but with a name that is more akin to the OOP concept of method overloading
that is actually being employed. Here's an example:

      # @overload def to_html(html, autolink = true)
      #   This docstring describes the specific overload only.
      #   @param [String] html the HTML
      #   @param [Boolean] autolink whether or not to atuomatically link
      #     URL references
      # @overload def to_html(html, opts = {})
      #   @param [String] html the HTML
      #   @param [Hash] opts any attributes to add to the root HTML node
      def to_html(*args)
        # split args depending on context
      end
      
As you can see each overload takes its own nested tags (including a docstring)
as if it were its own method. This allows "virtual" overloading behaviour at
the API level to make Ruby look like overload-aware languages without caring
about the implementation details required to add the behaviour.

It is still recommended practice, however, to stay away from overloading when
possible and document the types of each method's real parameters. This allows
toolkits making use of YARD to get accurate type information for your methods,
for instance, allowing IDE autocompletion. There are, of course, situations
where overload just makes more sense.

Better documentation
--------------------

The first few iterations of YARD were very much a proof of concept. Few people
were paying attention and it was really just pieced together to see what was
feasible. Now that YARD is gaining interest, there are many developers that
want to take advantage of its extensibility support to do some really cool stuff.
Considerable time was spent for this release documenting, at a high level, what
YARD can do and how it can be done. Expect this documentation to be extended and
improved in future releases.

Template changes and bug fixes
------------------------------

Of course no new release would be complete without fixing the old broken code.
Some tags existed but were not present in generated documentation. The templates
were mostly fixed to add the major omitted tags. In addition to template adjustments,
many parsing bugs were ironed out to make YARD much more stable with existing projects
(Rails, HAML, Sinatra, Ramaze, etc.).

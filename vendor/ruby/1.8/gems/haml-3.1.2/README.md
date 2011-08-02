# Haml

Haml is a templating engine for HTML.
It's are designed to make it both easier and more pleasant
to write HTML documents,
by eliminating redundancy,
reflecting the underlying structure that the document represents,
and providing elegant, easily understandable, and powerful syntax.

## Using

Haml can be used from the command line
or as part of a Ruby web framework.
The first step is to install the gem:

    gem install haml

After you convert some HTML to Haml, you can run

    haml document.haml

to compile them.
For more information on these commands, check out

    haml --help

To install Haml in Rails 2,
just add `config.gem "haml"` to `config/environment.rb`.
In Rails 3, add `gem "haml"` to your Gemfile instead.
and both Haml and Sass will be installed.
Views with the `.html.haml` extension will automatically use Haml.

To use Haml programatically,
check out the [YARD documentation](http://haml-lang.com/docs/yardoc/).

## Formatting

The most basic element of Haml
is a shorthand for creating HTML:

    %tagname{:attr1 => 'value1', :attr2 => 'value2'} Contents

No end-tag is needed; Haml handles that automatically.
If you prefer HTML-style attributes, you can also use:

    %tagname(attr1='value1' attr2='value2') Contents

Adding `class` and `id` attributes is even easier.
Haml uses the same syntax as the CSS that styles the document:

    %tagname#id.class

In fact, when you're using the `<div>` tag,
it becomes _even easier_.
Because `<div>` is such a common element,
a tag without a name defaults to a div. So

    #foo Hello!

becomes

    <div id='foo'>Hello!</div>

Haml uses indentation
to bring the individual elements to represent the HTML structure.
A tag's children are indented beneath than the parent tag.
Again, a closing tag is automatically added.
For example:

    %ul
      %li Salt
      %li Pepper

becomes:

    <ul>
      <li>Salt</li>
      <li>Pepper</li>
    </ul>

You can also put plain text as a child of an element:

    %p
      Hello,
      World!

It's also possible to embed Ruby code into Haml documents.
An equals sign, `=`, will output the result of the code.
A hyphen, `-`, will run the code but not output the result.
You can even use control statements
like `if` and `while`:

    %p
      Date/Time:
      - now = DateTime.now
      %strong= now
      - if now > DateTime.parse("December 31, 2006")
        = "Happy new " + "year!"

Haml provides far more tools than those presented here.
Check out the [reference documentation](http://beta.haml-lang.com/docs/yardoc/file.HAML_REFERENCE.html)
for full details.

### Indentation

Haml's indentation can be made up of one or more tabs or spaces.
However, indentation must be consistent within a given document.
Hard tabs and spaces can't be mixed,
and the same number of tabs or spaces must be used throughout.

## Authors

Haml was created by [Hampton Catlin](http://hamptoncatlin.com)
(hcatlin) and he is the author of the original implementation. However, Hampton
doesn't even know his way around the code anymore and now occasionally consults
on the language issues.  Hampton lives in Jacksonville, Florida and is the lead
mobile developer for Wikimedia.

[Nathan Weizenbaum](http://nex-3.com) is the primary developer and architect of
the "modern" Ruby implementation of Haml. His hard work has kept the project
alive by endlessly answering forum posts, fixing bugs, refactoring, finding
speed improvements, writing documentation, implementing new features, and
getting Hampton coffee (a fitting task for a boy-genius). Nathan lives in
Seattle, Washington and while not being a student at the University of
Washington or working at an internship, he consults for Unspace Interactive.

If you use this software, you must pay Hampton a compliment. And
buy Nathan some jelly beans. Maybe pet a kitten. Yeah. Pet that kitty.

Some of the work on Haml was supported by Unspace Interactive.

Beyond that, the implementation is licensed under the MIT License.
Okay, fine, I guess that means compliments aren't __required__.

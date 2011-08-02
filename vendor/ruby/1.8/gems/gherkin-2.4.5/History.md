## [2.4.5](https://github.com/cucumber/gherkin/compare/v2.4.4...v2.4.5)

No changes, releasing again since the 2.4.4 release failed halfway through.

## [2.4.4](https://github.com/cucumber/gherkin/compare/v2.4.3...v2.4.4)

### Bugfixes
* JRuby fixes. Symbols and streams are now properly converted before passing from ruby to java. (Aslak Hellesøy)
* json-simple and base64 jar files (used by some of the java classes) are now embedded in the jruby gem (Aslak Hellesøy)

## [2.4.3](https://github.com/cucumber/gherkin/compare/v2.4.2...v2.4.3)

### Changed Features
* Added a small hack to the java Result class to work around [Cucumber bug #97](https://github.com/cucumber/cucumber/issues/97) (Aslak Hellesøy)

## [2.4.2](https://github.com/cucumber/gherkin/compare/v2.4.1...v2.4.2)

### Changed Features
* Formatter and Reporter are now two distinct interfaces. JSONParser takes one of each in ctor. (Aslak Hellesøy)

## [2.4.1](https://github.com/cucumber/gherkin/compare/v2.4.0...v2.4.1)

### New Features
* None - just updated build system to the latest Cucumber (Aslak Hellesøy)

## [2.4.0](https://github.com/cucumber/gherkin/compare/v2.3.10...v2.4.0)

### Bugfixes
* Don't use -Werror in production code ([#106](https://github.com/cucumber/gherkin/pull/106) Hans de Graaff)

### New Features
* YARD based API docs at http://cukes.info/gherkin/api/ruby/latest/ (Aslak Hellesøy)

### Changed Features
* py_string/PyString changed to doc_string/DocString, ref https://github.com/cucumber/cucumber/issues/74 (Aslak Hellesøy)

## [2.3.10](https://github.com/cucumber/gherkin/compare/v2.3.9...v2.3.10)

### Bugfixes
* Relax development dependency version on builder. (#105 Aslak Hellesøy).

## [2.3.9](https://github.com/cucumber/gherkin/compare/v2.3.8...v2.3.9)

### New features
* Javascript lexers support http://requirejs.org/ modules as well as node.js (Aslak Hellesøy).

## [2.3.8](https://github.com/cucumber/gherkin/compare/v2.3.7...v2.3.8)

### Insignificant changes
* Improve build system so we don't need to add generated js lexers to git.

## [2.3.7](https://github.com/cucumber/gherkin/compare/v2.3.6...v2.3.7)

* Removed incorrect (and unneeded) case statement that could blow up if V8 is installed. (Aslak Hellesøy, Niklas H)
* Added connect support for gherkin.js (Aslak Hellesøy)

## [2.3.6](https://github.com/cucumber/gherkin/compare/v2.3.5...v2.3.6)

### New Features
* Javascript implementation (#38 Aslak Hellesøy)

### Bugfixes
* Fix compilation error on Arch Linux (#98,#99 Ben Hamill)
* Corrected Russian translation (#97 Vagif Abilov)

## [2.3.5](https://github.com/cucumber/gherkin/compare/v2.3.4...v2.3.5)

### Changes
* Relaxed gem dependencies to use >=. (Rob Slifka, Aslak Hellesøy)

## [2.3.4](https://github.com/cucumber/gherkin/compare/v2.3.3...v2.3.4)

### Changes
* Fixing C90 errors on Ubuntu Natty (#92 Colin Dean)
* Romanian (ro) language update, extracted from a real-world project. (Iulian Dogariu)

## [2.3.3](https://github.com/cucumber/gherkin/compare/v2.3.2...v2.3.3)

### Changes
* No more dependencies on external ANSI escape libraries (Ruby:term-ansicolor, Java:Jansi). DIY is better! (Aslak Hellesøy)
* Added duration (in millseconds) to Result. (Aslak Hellesøy)
* Additional Polish aliases (Mike Połtyn)

## [2.3.2](https://github.com/cucumber/gherkin/compare/v2.3.0...v2.3.2)

(Somehow 2.3.1 was released improperly shortly after 2.3.0 - not sure what fixes went into that!)

### Bugfixes
* Preserve whitespace in descriptions. Leading whitespace in descriptions are stripped upto preceding keyword + 2 spaces (#87 Matt Wynne, Gregory Hnatiuk, Aslak Hellesøy)
* Fix incorrect indentation of Examples descriptions (Gregory Hnatiuk)
* Can't define new line characters in Example Table Cell's Content. (#85 George Montana Harkin, Aslak Hellesøy)

## [2.3.0](https://github.com/cucumber/gherkin/compare/v2.2.9...v2.3.0)

### New Features
* New aliases for Scenario Outline in Swedish, Norwegian and English. (Peter Krantz, Aslak Hellesøy)
* Improved build documentation for people who want to contribute. (Aslak Hellesøy)
* Results can now be outputted/parsed in JSON. (Aslak Hellesøy)
* JSON output now contains optional "match", "result" and "embeddings" elements underneath each step. (Aslak Hellesøy)
* Added support for Base64 encoded embeddings in JSON representation. Useful for screenshots etc. (Aslak Hellesøy)

## [2.2.9](https://github.com/cucumber/gherkin/compare/v2.2.8...v2.2.9)

### New Features
* PrettyFormatter can format features both with and without ANSI Colors. Using Jansi on Java. (Aslak Hellesøy)
* Extended Java Formatter API with a steps(List<Step>) method for better reporting in Java (Aslak Hellesøy)

## [2.2.8](https://github.com/cucumber/gherkin/compare/v2.2.7...v2.2.8)

### Removed Features
* Trollop based CLI - didn't find a good use for it yet. (Aslak Hellesøy)

## [2.2.7](https://github.com/cucumber/gherkin/compare/v2.2.6...v2.2.7)

### Bugfixes
* I18n.getCodeKeywords() on Java didn't strip '!'. Not anymore. (Aslak Hellesøy)

## [2.2.6](https://github.com/cucumber/gherkin/compare/v2.2.5...v2.2.6)

### Bugfixes
* I18n.getCodeKeywords() on Java included '*'. Not anymore. (Aslak Hellesøy)

## [2.2.5](https://github.com/cucumber/gherkin/compare/v2.2.4...v2.2.5)

### New Features
* Gherkin will scan all top comments for the language comment. (Aslak Hellesøy)

## [2.2.4](https://github.com/cucumber/gherkin/compare/v2.2.3...v2.2.4)

### Bugfixes
* C99 features used by gherkin code (#75 Graham Agnew)

## [2.2.3](https://github.com/cucumber/gherkin/compare/v2.2.2...v2.2.3)

### Bugfixes
* Add back missing development dependency on cucumber (Aslak Hellesøy)

## [2.2.2](https://github.com/cucumber/gherkin/compare/v2.2.1...v2.2.2)

### New Features
* Use json instead of json_pure (Aslak Hellesøy)
* JSON formatter and parser can now omit JSON serialization (for speed) and work directly on objects (Aslak Hellesøy)

## [2.2.1](https://github.com/cucumber/gherkin/compare/v2.2.0...v2.2.1)

### New Features
* Windows gems are now built against 1.8.6-p287 and 1.9.1-p243, on both mswin32 and mingw32, and should work on 1.8.6, 1.8.7, 1.9.1 and 1.9.2 versions of rubyinstaller.org as well as older windows rubies. (Aslak Hellesøy)

### Changed features
* Build system no longer uses Jeweler - only Rake, Bundler and Rubygems (Aslak Hellesøy)

## [2.2.0](https://github.com/cucumber/gherkin/compare/v2.1.5...v2.2.0)

This release breaks some APIs since the previous 2.1.5 release. If you install gherkin 2.2.0 you must also upgrade to
Cucumber 0.9.0.

### Bugfixes
* I18nLexer doesn't recognise language header with \r\n on OS X. (#70 Aslak Hellesøy)

### New Features
* Pure Java FilterFormatter. (Aslak Hellesøy)
* Pure Java JSONFormatter. (Aslak Hellesøy)

### Changed Features
* All formatter events take exactly one argument. Each argument is a single object with all data. (Aslak Hellesøy)
* Several java classes have moved to a different package in order to improve separation of concerns. (Aslak Hellesøy)

## [2.1.5](https://github.com/cucumber/gherkin/compare/v2.1.4...v2.1.5)

### Bugfixes
* Line filter works on JRuby with Scenarios without steps. (Aslak Hellesøy)

### Changed Features
* The JSON schema now puts background inside the "elements" Array. Makes parsing simpler. (Aslak Hellesøy)

## [2.1.4](https://github.com/cucumber/gherkin/compare/v2.1.3...v2.1.4)

### Bugfixes
* #steps fails on JRuby with 2.1.3 (#68 Aslak Hellesøy)

## [2.1.3](https://github.com/cucumber/gherkin/compare/v2.1.2...v2.1.3)

### Bugfixes
* Examples are not cleared when an ignored Scenario Outline/Examples is followed by a Scenario. (#67 Aslak Hellesøy)

## [2.1.2](https://github.com/cucumber/gherkin/compare/v2.1.1...v2.1.2)

### Bugfixes
* Fix some missing require statements that surfaced when gherkin was used outside Cucumber. (Aslak Hellesøy)

## [2.1.1](https://github.com/cucumber/gherkin/compare/v2.1.0...v2.1.1)

The previous release had a missing gherkin.jar in the jruby gem. This release fixes that. For good this time!

## [2.1.0](https://github.com/cucumber/gherkin/compare/v2.0.2...v2.1.0)

### New Features
* Pirate! (anteaya)
* Tag limits for negative tags (Aslak Hellesøy)

### Changed Features
* The formatter API has changed and the listener API is now only used internally. (Aslak Hellesøy)

### Removed Features
* FilterListener has been replaced with FilterFormatter. Currently only in Ruby (no Java impl yet). (Aslak Hellesøy)

## [2.0.2](https://github.com/cucumber/gherkin/compare/v2.0.1...v2.0.2)

### New Features
* New JSON Lexer. (Gregory Hnatiuk)

### Bugfixes
* Fixed incorrect indentation for descriptions in Java. (Aslak Hellesøy)
* Fixed support for xx-yy languages and Hebrew and Indonesian (JDK bugs). (Aslak Hellesøy)

### Changed Features
* Examples are now nested inside the Scenario Outline in the JSON format. (Gregory Hnatiuk)

## [2.0.1](https://github.com/cucumber/gherkin/compare/v2.0.0...v2.0.1)

The previous release had a missing gherkin.jar in the jruby gem. This release fixes that.

## [2.0.0](https://github.com/cucumber/gherkin/compare/v1.0.30...v2.0.0)

We're breaking the old listener API in this release, and added a new JSON formatter,
which calls for a new major version.

### New Features
* New JSON formatter. (Aslak Hellesøy, Joseph Wilk)
* New synonyms for Hungarian (Bence Golda)
* Upgraded to use RSpec 2.0.0 (Aslak Hellesøy)

### Bugfixes
* undefined method `<=>' on JRuby (#52 Aslak Hellesøy)
* Include link to explanation of LexingError (Mike Sassak)

### Changed Features
* The formatter API has completely changed. There is a Gherkin Listener API and a Formatter API.
  The FormatterListener acts as an adapter between them. (Aslak Hellesøy)
* The listener API now has an additional argument for description (text following the first line of Feature:, Scenario: etc.) (Gregroy Hnatiuk, Matt Wynne)

## [1.0.30](https://github.com/cucumber/gherkin/compare/v1.0.29...v1.0.30)

### New Features
* Native gems for IronRuby. Bundles IKVM OpenJDK dlls as well as ikvmc-compiled gherkin.dll. Experimental! (Aslak Hellesøy)

## [1.0.29](https://github.com/cucumber/gherkin/compare/v1.0.28...v1.0.29)

### Bugfixes
* Use I18n.class' class loader instead of context class loader to load Java lexers. Hoping this fixes loading bug for good. (Aslak Hellesøy)

## [1.0.28](https://github.com/cucumber/gherkin/compare/v1.0.27...v1.0.28)

### Bugfixes
* Use context class loader instead of boot class loader to load Java lexers. (Aslak Hellesøy)
* Only add gcc flags when the compiler is gcc. (#60 Aslak Hellesøy, Christian Höltje)

## [1.0.27](https://github.com/cucumber/gherkin/compare/v1.0.26...v1.0.27)

### New Features
* Table cells can now contain escaped bars - \| and escaped backslashes - \\. (#48. Gregory Hnatiuk, Aslak Hellesøy)
* Luxemburgish (lu) added. (Christoph König)

## [1.0.26](https://github.com/cucumber/gherkin/compare/v1.0.25...v1.0.26)

### New Features
* Ignore the BOM that many retarded Windows editors insist on sticking in the beginning of a file. (Aslak Hellesøy)

## [1.0.25](https://github.com/cucumber/gherkin/compare/v1.0.24...v1.0.25)

### Bugfixes
* Allow fallback to a slower ruby lexer if the C lexer can't be loaded for some reason.
* Can't run specs in gherkin 1.0.24 (#59 Aslak Hellesøy)

## [1.0.24](https://github.com/cucumber/gherkin/compare/v1.0.23...v1.0.24)

### Bugfixes
* hard tabs crazy indentation for pystrings in formatter (#55 Aslak Hellesøy)

## [1.0.23](https://github.com/cucumber/gherkin/compare/v1.0.22...v1.0.23)

### Changed Features
* Java API now uses camelCased method names instead of underscored (more Java-like) (Aslak Hellesøy)

## [1.0.22](https://github.com/cucumber/gherkin/compare/v1.0.21...v1.0.22)

### Bugfixes
* Make prebuilt binaries work on both Ruby 1.8.x and 1.9.x on Windows (#54 Luis Lavena, Aslak Hellesøy)

## [1.0.21](https://github.com/cucumber/gherkin/compare/v1.0.20...v1.0.21)

### Bugfixes
* Fix compile warning on ruby 1.9.2dev (2009-07-18 trunk 24186) (#53 Aslak Hellesøy)

## [1.0.20](https://github.com/cucumber/gherkin/compare/v1.0.19...v1.0.20)

### Bugfixes
* The gherkin CLI is working again (Gregory Hnatiuk)

## [1.0.19](https://github.com/cucumber/gherkin/compare/v1.0.18...v1.0.19)

### New Features
* Works with JRuby 1.5.0.RC1 (Aslak Hellesøy)

### Changed Features
* I18n.code_keywords now return And and But as well, making Cucumber StepDefs a little more flexible (Aslak Hellesøy)

## [1.0.18](https://github.com/cucumber/gherkin/compare/v1.0.17...v1.0.18)

### Bugfixes
* Explicitly use UTF-8 encoding when scanning source with Java lexer. (Aslak Hellesøy)

## [1.0.17](https://github.com/cucumber/gherkin/compare/v1.0.16...v1.0.17)

### Bugfixes
* Gherkin::I18n.keyword_regexp was broken (used for 3rd party code generation). (#51 Aslak Hellesøy)

## [1.0.16](https://github.com/cucumber/gherkin/compare/v1.0.15...v1.0.16)
(Something went wrong when releasing 1.0.15)

### Bugfixes
* Reduced risk of halfway botched releases. (Aslak Hellesøy)

## [1.0.15](https://github.com/cucumber/gherkin/compare/v1.0.14...v1.0.15)

### New Features
* Implemented more functionality in I18n.java. (Aslak Hellesøy)

### Changed Features
* Java methods are no longer throwing Exception (but RuntimeException). (Aslak Hellesøy)

## [1.0.14](https://github.com/cucumber/gherkin/compare/v1.0.13...v1.0.14)
(Something went wrong when releasing 1.0.13)

## [1.0.13](https://github.com/cucumber/gherkin/compare/v1.0.12...v1.0.13)

### New Features
* Filter on Background name. (Aslak Hellesøy)

## [1.0.12](https://github.com/cucumber/gherkin/compare/v1.0.11...v1.0.12)

### Bugfixes
* Fixed incorrect filtering of pystring in Background. (Mike Sassak)

## [1.0.11](https://github.com/cucumber/gherkin/compare/v1.0.10...v1.0.11)

### Bugfixes
* Fixed bad packaging (C files were not packaged in POSIX gem)

## [1.0.10](https://github.com/cucumber/gherkin/compare/v1.0.09...v1.0.10)

### New Features
* Added Esperanto and added a Russian synonym for Feature. (Antono Vasiljev)
* Pure Java implementation of FilterListener and TagExpression (Mike Gaffney, Aslak Hellesøy)

### Changed Features
* TagExpression takes array args instead of varargs. (Aslak Hellesøy)

## [1.0.9](https://github.com/cucumber/gherkin/compare/v1.0.8...v1.0.9)

### Bugfixes
* Triple escaped quotes (\"\"\") in PyStrings are unescaped to """. (Aslak Hellesøy)

## [1.0.8](https://github.com/cucumber/gherkin/compare/v1.0.7...v1.0.8)

### Bugfixes
* Removed illegal comma from Ukrainian synonym. (Aslak Hellesøy)

## [1.0.7](https://github.com/cucumber/gherkin/compare/v1.0.6...v1.0.7)

### Bugfixes
* Fixed problems with packaging of 1.0.6 release. (Aslak Hellesøy)

## [1.0.6](https://github.com/cucumber/gherkin/compare/v1.0.5...v1.0.6)

### New Features
* Fully automated release process. (Aslak Hellesøy)

### Changed Features
* Made generated classes use a more uniform naming convention. (Aslak Hellesøy)

### Removed Features
* Removed C# port, obsoleted by IKVM build from 1.0.5. (Aslak Hellesøy)

## [1.0.5](https://github.com/cucumber/gherkin/compare/v1.0.4...v1.0.5)

### New Features
* New .NET build of gherkin - an ikvmc build of gherkin.jar to gherkin.dll. (Aslak Hellesøy)

### Bugfixes
* Made parsers reusable so that the same instance can parse several features. (Aslak Hellesøy)

## [1.0.4](https://github.com/cucumber/gherkin/compare/v1.0.3...v1.0.4)

### New features
* Pure java releases of Gherkin at http://cukes.info/maven
* A FilterListener in Ruby that is the last missing piece to plug Gherkin into Cucumber. (Gregory Hnatiuk, Aslak Hellesøy, Matt Wynne, Mike Sassak)

### Changed features
* The Lexer now emits the '@' for tags. (Aslak Hellesøy)

## [1.0.3](https://github.com/cucumber/gherkin/compare/v1.0.2...v1.0.3)

### Bugfixes
* The C lexer correctly instantiates a new array for each table, instead of reusing the old one. (Aslak Hellesøy)
* Emit keywords with space instead of stripping (< keywords are emmitted without space) (Aslak Hellesøy)
* gherkin reformat now prints comments, and does it with proper indentation (Aslak Hellesøy)
* .NET resource files are now automatically copied into the .dll (#46 Aslak Hellesøy)

### New features
* The Pure Java implementation now has a simple main method that pretty prints a feature. (#39 Aslak Hellesøy) 
* Writing code generated i18n syntax highlighters for Gherkin is a lot easier thanks to several convenience methods in Gherkin::I18n. (Aslak Hellesøy)
* .NET (C#) port (#36, #37 Attila Sztupak)
* Tables parsed and sent by row rather than by table. (Mike Sassak)

### Changed features
* Switced to ISO 639-1 (language) and ISO 3166 alpha-2 (region - if applicable). Applies to Catalan,
  Swedish, Welsh, Romanian and Serbian. (Aslak Hellesøy)

## [1.0.2](https://github.com/cucumber/gherkin/compare/v1.0.1...v1.0.2)

### Bugfixes
* Build passes on Ruby 1.9.2 (Aslak Hellesøy)

### New features
* New command line based on trollop. Commands: reformat, stats. (Aslak Hellesøy)
* I18nLexer#scan sets #language to the I18n for the language scanned (Mike Sassak)
* I18n#adverbs, brings I18n to parity with Cucumber::Parser::NaturalLanguage (Mike Sassak)

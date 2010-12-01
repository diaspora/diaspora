#! /usr/bin/env rake
#--
# MIME::Types
# A Ruby implementation of a MIME Types information library. Based in spirit
# on the Perl MIME::Types information library by Mark Overmeer.
# http://rubyforge.org/projects/mime-types/
#
# Licensed under the Ruby disjunctive licence with the GNU GPL or the Perl
# Artistic licence. See Licence.txt for more information.
#
# Copyright 2003 - 2009 Austin Ziegler
#++

require 'rubygems'
require 'hoe'

$LOAD_PATH.unshift('lib')

require 'mime/types'

PKG_NAME    = 'mime-types'
PKG_VERSION = MIME::Types::VERSION
PKG_DIST    = "#{PKG_NAME}-#{PKG_VERSION}"
PKG_TAR     = "pkg/#{PKG_DIST}.tar.gz"
MANIFEST    = File.read("Manifest.txt").split

hoe = Hoe.new PKG_NAME, PKG_VERSION do |p|
  p.rubyforge_name  = PKG_NAME
  # This is a lie because I will continue to use Archive::Tar::Minitar.
  p.need_tar        = false
  # need_zip - Should package create a zipfile? [default: false]

  p.author          = [ "Austin Ziegler" ]
  p.email           = %W(austin@rubyforge.org)
  p.url             = "http://mime-types.rubyforge.org/"
  p.summary         = %q{Manages a MIME Content-Type database that will return the Content-Type for a given filename.}
  p.changes         = p.paragraphs_of("History.txt", 0..0).join("\n\n")
  p.description     = p.paragraphs_of("README.txt", 1..1).join("\n\n")

  p.extra_dev_deps  << %w(archive-tar-minitar ~>0.5)
  p.extra_dev_deps  << %w(nokogiri ~>1.2)
  p.extra_dev_deps  << %w(rcov ~>0.8)

  p.clean_globs     << "coverage"

  p.spec_extras[:extra_rdoc_files] = MANIFEST.grep(/txt$/) - ["Manifest.txt"]
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.libs << 'test'
    t.test_files = hoe.test_files
    t.verbose = true
  end
rescue LoadError
  puts "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
end

=begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)
rescue LoadError
  puts "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
=end

desc "Build a MIME::Types .tar.gz distribution."
task :tar => [ PKG_TAR ]
file PKG_TAR => [ :test ] do |t|
  require 'archive/tar/minitar'
  require 'zlib'
  files = MANIFEST.map { |f|
    fn = File.join(PKG_DIST, f)
    tm = File.stat(f).mtime

    if File.directory?(f)
      { :name => fn, :mode => 0755, :dir => true, :mtime => tm }
    else
      mode = if f =~ %r{^bin}
               0755
             else
               0644
             end
      data = File.read(f)
      { :name => fn, :mode => mode, :data => data, :size => data.size,
        :mtime => tm }
    end
  }

  begin
    unless File.directory?(File.dirname(t.name))
      require 'fileutils'
      FileUtils.mkdir_p File.dirname(t.name)
    end
    tf = File.open(t.name, 'wb')
    gz = Zlib::GzipWriter.new(tf)
    tw = Archive::Tar::Minitar::Writer.new(gz)

    files.each do |entry|
      if entry[:dir]
        tw.mkdir(entry[:name], entry)
      else
        tw.add_file_simple(entry[:name], entry) { |os|
          os.write(entry[:data])
        }
      end
    end
  ensure
    tw.close if tw
    gz.close if gz
  end
end
task :package => [ PKG_TAR ]

desc "Build the manifest file from the current set of files."
task :build_manifest do |t|
  require 'find'

  hoerc = File.join(File.dirname(__FILE__), ".hoerc")
  hoerc = File.open(hoerc, "rb") { |f| f.read }
  hoerc = YAML::load(hoerc)

  paths = []
  Find.find(".") do |path|
    next if File.directory?(path) || path =~ hoerc["exclude"]
    paths << path.sub(%r{^\./}, '')
  end

  paths = paths.sort.join("\n")

  File.open("Manifest.txt", "w") do |f|
    f.puts paths
  end

  puts paths
end

desc "Download the current MIME type registrations from IANA."
task :iana, :save, :destination do |t, args|
  save_type = args.save || :text
  save_type = save_type.to_sym

  case save_type
  when :text, :both, :html
    nil
  else
    raise "Unknown save type provided. Must be one of text, both, or html."
  end

  destination = args.destination || "type-lists"

  require 'open-uri'
  require 'nokogiri'
  require 'cgi'

  class IANAParser
    include Comparable

    INDEX = %q(http://www.iana.org/assignments/media-types/)
    CONTACT_PEOPLE = %r{http://www.iana.org/assignments/contact-people.html?#(.*)}
    RFC_EDITOR = %r{http://www.rfc-editor.org/rfc/rfc(\d+).txt}
    IETF_RFC = %r{http://www.ietf.org/rfc/rfc(\d+).txt}
    IETF_RFC_TOOLS = %r{http://tools.ietf.org/html/rfc(\d+)}

    class << self
      def load_index
        @types ||= {}

        Nokogiri::HTML(open(INDEX) { |f| f.read }).xpath('//p/a').each do |tag|
          href_match = %r{^/assignments/media-types/(.+)/$}.match(tag['href'])
          next if href_match.nil?
          type = href_match.captures[0]
          @types[tag.content] = IANAParser.new(tag.content, type)
        end
      end

      attr_reader :types
    end

    def initialize(name, type)
      @name = name
      @type = type
      @url  = File.join(INDEX, @type)
    end

    attr_reader :name
    attr_reader :type
    attr_reader :url
    attr_reader :html

    def download(name = nil)
      @html = Nokogiri::HTML(open(name || @url) { |f| f.read })
    end

    def save_html
      File.open("#@name.html", "wb") { |w| w.write @html }
    end

    def <=>(o)
      self.name <=> o.name
    end

    def parse
      nodes = html.xpath("//table//table//tr")

      # How many <td> children does the first node have?
      node_count = nodes.first.children.select { |node| node.elem? }.size

      @mime_types = nodes.map do |node|
        next if node == nodes.first
        elems = node.children.select { |n| n.elem? }
        next if elems.size.zero?
        raise "size mismatch #{elems.size} != #{node_count}" if node_count != elems.size

        case elems.size
        when 3
          subtype_index = 1
          refnode_index = 2
        when 4
          subtype_index = 1
          refnode_index = 3
        else
          raise "Unknown element size."
        end

        subtype   = elems[subtype_index].content.chomp.strip
        refnodes  = elems[refnode_index].children.select { |n| n.elem? }.map { |ref|
          case ref['href']
          when CONTACT_PEOPLE
            tag = CGI::unescape($1).chomp.strip
            if tag == ref.content
            "[#{ref.content}]"
            else
            "[#{ref.content}=#{tag}]"
            end
          when RFC_EDITOR, IETF_RFC, IETF_RFC_TOOLS
          "RFC#$1"
          when %r{(https?://.*)}
          "{#{ref.content}=#$1}"
          else
            ref
          end
        }
        refs = refnodes.join(',')

      "#@type/#{subtype} 'IANA,#{refs}"
      end.compact

      @mime_types
    end

    def save_text
      File.open("#@name.txt", "wb") { |w| w.write @mime_types.join("\n") }
    end
  end

  puts "Downloading index of MIME types from #{IANAParser::INDEX}."
  IANAParser.load_index

  require 'fileutils'
  FileUtils.mkdir_p destination
  Dir.chdir destination do
    IANAParser.types.values.sort.each do |parser|
      next if parser.name == "example" or parser.name == "mime"
      puts "Downloading #{parser.name} from #{parser.url}"
      parser.download

      if :html == save_type || :both == save_type
        puts "Saving #{parser.name}.html"
        parser.save_html
      end

      puts "Parsing #{parser.name} HTML"
      parser.parse

      if :text == save_type || :both == save_type
        puts "Saving #{parser.name}.txt"
        parser.save_text
      end
    end
  end
end

desc "Shows known MIME type sources."
task :mime_type_sources do
  puts <<-EOS
http://www.ltsw.se/knbase/internet/mime.htp
http://www.webmaster-toolkit.com/mime-types.shtml
http://plugindoc.mozdev.org/winmime.php
http://standards.freedesktop.org/shared-mime-info-spec/shared-mime-info-spec-latest.html  
http://www.feedforall.com/mime-types.htm
http://www.iana.org/assignments/media-types/
  EOS
end

desc "Validate the RubyGem spec for GitHub."
task :github_validate_spec do |t|
  require 'yaml'

  require 'rubygems/specification'
  data = File.read("#{PKG_NAME}.gemspec")
  spec = nil

  if data !~ %r{!ruby/object:Gem::Specification}
    code = "$SAFE = 3\n#{data}"
    p code.split($/)[44]
    Thread.new { spec = eval("$SAFE = 3\n#{data}") }.join
  else
    spec = YAML.load(data)
  end

  spec.validate

  puts spec
  puts "OK"
end

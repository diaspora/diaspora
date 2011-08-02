require 'rdoc/rdoc'
require 'gauntlet'
require 'fileutils'

##
# Allows for testing of RDoc against every gem

class RDoc::Gauntlet < Gauntlet

  ##
  # Runs an RDoc generator for gem +name+

  def run name
    return if self.data.key? name

    dir = File.expand_path "~/.gauntlet/data/rdoc/#{name}"
    FileUtils.rm_rf dir if File.exist? dir

    yaml = File.read 'gemspec'
    spec = Gem::Specification.from_yaml yaml

    args = %W[--ri --op #{dir}]
    args.push(*spec.rdoc_options)
    args << spec.require_paths
    args << spec.extra_rdoc_files
    args = args.flatten.map { |a| a.to_s }
    args.delete '--quiet'

    puts "#{name} - rdoc #{args.join ' '}"

    self.dirty = true
    r = RDoc::RDoc.new

    begin
      r.document args
      self.data[name] = true
      puts 'passed'
      FileUtils.rm_rf dir
    rescue Interrupt, StandardError, RDoc::Error, SystemStackError => e
      puts "failed - (#{e.class}) #{e.message}"
      self.data[name] = false
    end
  rescue Gem::Exception
    puts "bad gem #{name}"
  ensure
    puts
  end

end

RDoc::Gauntlet.new.run_the_gauntlet if $0 == __FILE__


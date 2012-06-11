#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
require Rails.root.join('lib', 'rake_helpers')
include RakeHelpers

namespace :invites do

  desc 'send a bunch of invites from a csv with rows of name, email'

  task :send, :number, :test do |t, args|
   require File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment')

    filename = Rails.root.join('config', 'mailing_list.csv')
    offset_filename = Rails.root.join('config', 'email_offset')
    number_of_backers = args[:number] ? args[:number].to_i : 1000

    offset =  if File.exists?(offset_filename)
                File.read(offset_filename).to_i
              else
                1
              end
    test = !(args[:test] == 'false')
    puts "emailing #{number_of_backers} people listed in #{filename} starting at #{offset}"

    finish_num = process_emails(filename, number_of_backers, offset, test)

    new_offset = offset + finish_num + 1
    File.open(Rails.root.join('config', 'email_offset'), 'w') do |f|
      f.write(new_offset)
    end
    puts "you ended on #{new_offset}"
    puts "all done"
  end
end

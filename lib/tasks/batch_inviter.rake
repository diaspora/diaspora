#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
require File.join(Rails.root, 'lib', 'rake_helpers')
include RakeHelpers

namespace :invites do

  desc 'send a bunch of invites from a csv with rows of name, email' 
 
  task :send, :filename, :number, :start do |t, args|
   puts "this task assumes the first line of your csv is just titles(1 indexed)"
   puts "MAKE SURE YOU HAVE RAN THIS ON THE RIGHT DB rake 'invites:send[filename, number, start] RAILS_ ENV=production'"
   puts Rails.env
   unless args[:filename]
      raise "please give me {filename.csv} {number of people to churn}, {where to start in the file}"
    end


   require File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment')

    filename = args[:filename]
    start = args[:start].to_i || 0
    number_of_backers = args[:number] || 1000
    offset = 1 + start
    puts "emailing #{number_of_backers.to_i} people listed in #{filename} starting at #{offset}"

    finish_num = process_emails(filename, number_of_backers.to_i, offset)

    puts "you ended on #{offset + finish_num}"
    puts "all done"
  end

end

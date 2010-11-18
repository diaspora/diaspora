#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

namespace :invites do

  desc 'send a bunch of invites from a csv with rows of name, email' 
  task :send, :filename, :number, :start do
    
  unless args[:filename] && args[:number] && args[:start]
    raise "please give me {filename} {number of people to churn}, {where to start in the file}"
  end


    require File.dirname(__FILE__) + '/../../config/environment'
    require 'fastercsv'
    
    filename = args[:filename]
    start = args[:start].to_i || 0
    number_of_backers = args[:number].to_i || 1000
    offset = 1 + start
    puts "emailing #{number_of_backers} listed in #{filename} starting at #{start}"
    backers = FasterCSV.read("bkr.csv")

    #number_of_backers.times do |n|
    #  backer_name = backers[n+offset][0]
    #  backer_email = backers[n+offset][1].gsub('.ksr', '')
    #  send_email(backer_name, backer_email)
    #end
  end
end

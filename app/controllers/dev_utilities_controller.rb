#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, 'lib/em-webfinger')
class DevUtilitiesController < ApplicationController
  before_filter :authenticate_user!, :except => [:set_backer_number, :log]
  include ApplicationHelper
  include RequestsHelper

  def zombiefriends
    render :nothing => true
    bkr_info  = backer_info
    if current_user.email == "tom@tom.joindiaspora.com"
      puts bkr_info.inspect
      bkr_info.each do |backer|
        backer_email = "#{backer['username']}@#{backer['username']}.joindiaspora.com"
       
        webfinger = EMWebfinger.new(backer_email)
        
        webfinger.on_person { |person|
          puts person.inspect
          if person.respond_to? :diaspora_handle
            rel_hash = {:person => person}
            logger.info "Zombiefriending #{backer['given_name']} #{backer['family_name']}"
            logger.info "Calling send_contact_request with #{rel_hash[:person]} and #{current_user.aspects.first}"
            begin 

            
              current_user.send_contact_request_to(rel_hash[:person], current_user.aspects.first)
          rescue Exception => e 
            logger.info e.inspect
            puts e.inspect
          end
          else
            puts "error: #{person}"
          end
          }
      end
    end
  end

  def zombiefriendaccept
    render :nothing => true
    Request.all.each{|r|
      current_user.accept_and_respond(r.id, current_user.aspects.first.id)
    }
  end

  def set_backer_number
    render :nothing => true
    seed_num_hash = {:seed_number => params[:number]}
    file = File.new(Rails.root.join('config','backer_number.yml'),'w')
    file.write(seed_num_hash.to_yaml)
    file.close
  end

  def set_profile_photo
    render :nothing => true

    backer_number = YAML.load_file(Rails.root.join('config','backer_number.yml'))[:seed_number].to_i
    username = backer_info[backer_number]['username'].gsub(/ /,'').downcase

      @fixture_name = File.join(File.dirname(__FILE__), "..", "..", "public", "images", "user", "#{username}.jpg")

      photo = current_user.post(:photo, :user_file => File.open(@fixture_name), :to => 'all')
      photo.save

      current_user.raw_visible_posts << photo
      current_user.save

     current_user.update_profile(:image_url => photo.url(:thumb_large))
     current_user.save
  end

  def log
    @log = `tail -n 200 log/development.log`

    render "shared/log"
  end

  protected

  def backer_info
    config = YAML.load_file(File.join(File.dirname(__FILE__), "..", "..", "config", "deploy_config.yml"))
    config['servers']['backer']
  end
end

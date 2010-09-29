#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

class DevUtilitiesController < ApplicationController
  before_filter :authenticate_user!, :except => [:set_backer_number]
  include ApplicationHelper
  include RequestsHelper

  def zombiefriends
    render :nothing => true
    bkr_info  = backer_info

    if current_user.email == "tom@tom.joindiaspora.com"
      bkr_info.each do |backer|
        backer_email = "#{backer['username']}@#{backer['username']}.joindiaspora.com"
        rel_hash = relationship_flow(backer_email)
        logger.info "Zombiefriending #{backer['given_name']} #{backer['family_name']}"
        logger.info "Calling send_friend_request with #{rel_hash[:friend]} and #{current_user.aspects.first}"
        current_user.send_friend_request_to(rel_hash[:friend], current_user.aspects.first)
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
    album = Album.create(:person => current_user.person, :name => "Profile Photos")
    current_user.raw_visible_posts << album
    current_user.save

    backer_number = YAML.load_file(Rails.root.join('config','backer_number.yml'))[:seed_number].to_i
    username = backer_info[backer_number]['username'].gsub(/ /,'').downcase

      @fixture_name = File.join(File.dirname(__FILE__), "..", "..", "public", "images", "user", "#{username}.jpg")

      photo = Photo.new(:person => current_user.person, :album => album)
      photo.image.store! File.open(@fixture_name)
      photo.save
      photo.reload

      current_user.raw_visible_posts << photo
      current_user.save

     current_user.update_profile(:image_url => photo.url(:thumb_medium))
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

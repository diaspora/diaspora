#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
module Diaspora; module Fetcher; class Public

  # various states that can be assigned to a person to describe where
  # in the process of fetching their public posts we're currently at
  Status_Initial = 0
  Status_Running = 1
  Status_Fetched = 2
  Status_Processed = 3
  Status_Done = 4
  Status_Failed  = 5
  Status_Unfetchable = 6

  # perform all actions necessary to fetch the public posts of a person
  # with the given diaspora_id
  def fetch! diaspora_id
    @person = Person.by_account_identifier diaspora_id
    return unless qualifies_for_fetching?

    begin
      retrieve_and_process_posts
    rescue => e
      set_fetch_status Public::Status_Failed
      raise e
    end

    set_fetch_status Public::Status_Done
  end

  private
    # checks, that public posts for the person can be fetched,
    # if it is reasonable to do so, and that they have not been fetched already
    def qualifies_for_fetching?
      raise ActiveRecord::RecordNotFound unless @person.present?
      return false if @person.fetch_status == Public::Status_Unfetchable

      # local users don't need to be fetched
      if @person.local?
        set_fetch_status Public::Status_Unfetchable
        return false
      end

      # this record is already being worked on
      return false if @person.fetch_status > Public::Status_Initial

      # ok, let's go
      @person.remote? &&
      @person.fetch_status == Public::Status_Initial
    end

    # call the methods to fetch and process the public posts for the person
    # does some error logging, in case of an exception
    def retrieve_and_process_posts
      begin
        retrieve_posts
      rescue => e
        FEDERATION_LOGGER.error "unable to retrieve public posts for #{@person.diaspora_handle}"
        raise e
      end

      begin
        process_posts
      rescue => e
        FEDERATION_LOGGER.error "unable to process public posts for #{@person.diaspora_handle}"
        raise e
      end
    end

    # fetch the public posts of the person from their server and save the
    # JSON response to `@data`
    def retrieve_posts
      set_fetch_status Public::Status_Running

      FEDERATION_LOGGER.info "fetching public posts for #{@person.diaspora_handle}"

      resp = Faraday.get("#{@person.url}people/#{@person.guid}") do |req|
        req.headers[:accept] = 'application/json'
        req.headers[:user_agent] = 'diaspora-fetcher'
      end

      FEDERATION_LOGGER.debug resp.body.to_s[0..250]

      @data = JSON.parse resp.body
      set_fetch_status Public::Status_Fetched
    end

    # process the public posts that were previously fetched with `retrieve_posts`
    # adds posts, which pass some basic sanity-checking
    # @see validate
    def process_posts
      @data.each do |post|
        next unless validate(post)

        FEDERATION_LOGGER.info "saving fetched post (#{post['guid']}) to database"

        FEDERATION_LOGGER.debug post.to_s[0..250]

        # disable some stuff we don't want for bulk inserts
        StatusMessage.skip_callback :create, :set_guid

        entry = StatusMessage.diaspora_initialize(
          :author => @person,
          :public => true
        )
        entry.assign_attributes({
          :guid => post['guid'],
          :text => post['text'],
          :provider_display_name => post['provider_display_name'],
          :created_at => ActiveSupport::TimeZone.new('UTC').parse(post['created_at']).to_datetime,
          :interacted_at => ActiveSupport::TimeZone.new('UTC').parse(post['interacted_at']).to_datetime,
          :frame_name => post['frame_name']
        })
        entry.save

        # re-enable everything we disabled before
        StatusMessage.set_callback :create, :set_guid

      end
      set_fetch_status Public::Status_Processed
    end

    # set and save the fetch status for the current person
    def set_fetch_status status
      return if @person.nil?

      @person.fetch_status = status
      @person.save
    end

    # perform various validations to make sure the post can be saved without
    # troubles
    # @see check_existing
    # @see check_author
    # @see check_public
    # @see check_type
    def validate post
      check_existing(post) && check_author(post) && check_public(post) && check_type(post)
    end

    # hopefully there is no post with the same guid somewhere already...
    def check_existing post
      new_post = (Post.find_by_guid(post['guid']).blank?)

      FEDERATION_LOGGER.warn "a post with that guid (#{post['guid']}) already exists" unless new_post

      new_post
    end

    # checks if the author of the given post is actually from the person
    # we're currently processing
    def check_author post
      guid = post['author']['guid']
      equal = (guid == @person.guid)

      FEDERATION_LOGGER.warn "the author (#{guid}) does not match the person currently being processed (#{@person.guid})" unless equal

      equal
    end

    # returns wether the given post is public
    def check_public post
      ispublic = (post['public'] == true)

      FEDERATION_LOGGER.warn "the post (#{post['guid']}) is not public, this is not intended..." unless ispublic

      ispublic
    end

    # see, if the type of the given post is something we can handle
    def check_type post
      type_ok = (post['post_type'] == "StatusMessage")

      FEDERATION_LOGGER.warn "the post (#{post['guid']}) has a type, which cannot be handled (#{post['post_type']})" unless type_ok

      type_ok
    end
end; end; end

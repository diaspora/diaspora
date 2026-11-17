# frozen_string_literal: true

#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
module Diaspora
  module Fetcher
    class Public
      include Diaspora::Logging

      # various states that can be assigned to a person to describe where
      # in the process of fetching their public posts we're currently at
      STATUS_INITIAL = 0
      STATUS_RUNNING = 1
      STATUS_FETCHED = 2
      STATUS_PROCESSED = 3
      STATUS_DONE = 4
      STATUS_FAILED = 5
      STATUS_UNFETCHABLE = 6

      def self.queue_for(person)
        FetchPublicPostsWorker.perform_async(person.diaspora_handle) unless person.fetch_status > STATUS_INITIAL
      end

      # perform all actions necessary to fetch the public posts of a person
      # with the given diaspora_id
      def fetch!(diaspora_id)
        @person = Person.by_account_identifier diaspora_id
        return unless qualifies_for_fetching?

        begin
          retrieve_and_process_posts
        rescue StandardError => e
          update_fetch_status(Public::STATUS_FAILED)
          raise e
        end

        update_fetch_status(Public::STATUS_DONE)
      end

      private

      # checks, that public posts for the person can be fetched,
      # if it is reasonable to do so, and that they have not been fetched already
      def qualifies_for_fetching?
        raise ActiveRecord::RecordNotFound if @person.blank?
        return false if @person.fetch_status == Public::STATUS_UNFETCHABLE

        # local users don't need to be fetched
        if @person.local?
          update_fetch_status(Public::STATUS_UNFETCHABLE)
          return false
        end

        # this record is already being worked on
        return false if @person.fetch_status > Public::STATUS_INITIAL

        # ok, let's go
        @person.remote? &&
          @person.fetch_status == Public::STATUS_INITIAL
      end

      # call the methods to fetch and process the public posts for the person
      # does some error logging, in case of an exception
      def retrieve_and_process_posts
        begin
          retrieve_posts
        rescue StandardError => e
          logger.error "unable to retrieve public posts for #{@person.diaspora_handle}"
          raise e
        end

        begin
          process_posts
        rescue StandardError => e
          logger.error "unable to process public posts for #{@person.diaspora_handle}"
          raise e
        end
      end

      # fetch the public posts of the person from their server and save the
      # JSON response to `@data`
      def retrieve_posts
        update_fetch_status(Public::STATUS_RUNNING)

        logger.info "fetching public posts for #{@person.diaspora_handle}"

        resp = Faraday.get("#{@person.url}people/#{@person.guid}/stream") do |req|
          req.headers["Accept"] = "application/json"
          req.headers["User-Agent"] = "diaspora-fetcher"
        end

        logger.debug "fetched response: #{resp.body.to_s[0..250]}"

        @data = JSON.parse resp.body
        update_fetch_status(Public::STATUS_FETCHED)
      end

      # process the public posts that were previously fetched with `retrieve_posts`
      # adds posts, which pass some basic sanity-checking
      # @see validate
      def process_posts
        @data.each do |post|
          next unless validate(post)

          logger.info "saving fetched post (#{post['guid']}) to database"

          logger.debug "post: #{post.to_s[0..250]}"

          DiasporaFederation::Federation::Fetcher.fetch_public(
            @person.diaspora_handle,
            :post,
            post["guid"]
          )
        rescue DiasporaFederation::Federation::Fetcher::NotFetchable => e
          logger.warn e.message
        end
        update_fetch_status(Public::STATUS_PROCESSED)
      end

      # set and save the fetch status for the current person
      def update_fetch_status(status)
        return if @person.nil?

        @person.fetch_status = status
        @person.save
      end

      # perform various validations to make sure the post can be saved without
      # troubles
      # @see check_existing
      # @see check_author
      # @see check_public
      def validate(post)
        check_existing(post) && check_author(post) && check_public(post)
      end

      # hopefully there is no post with the same guid somewhere already...
      def check_existing(post)
        new_post = Post.find_by(guid: post["guid"]).blank?

        logger.warn "a post with that guid (#{post['guid']}) already exists" unless new_post

        new_post
      end

      # checks if the author of the given post is actually from the person
      # we're currently processing
      def check_author(post)
        guid = post["author"]["guid"]
        equal = (guid == @person.guid)

        unless equal
          logger.warn "the author (#{guid}) does not match the person currently being processed (#{@person.guid})"
        end

        equal
      end

      # returns wether the given post is public
      def check_public(post)
        ispublic = (post["public"] == true)

        logger.warn "the post (#{post['guid']}) is not public, this is not intended..." unless ispublic

        ispublic
      end
    end
  end
end

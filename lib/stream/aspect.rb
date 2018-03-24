# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Stream::Aspect < Stream::Base

  # @param user [User]
  # @param inputted_aspect_ids [Array<Integer>] Ids of aspects for given stream
  # @param aspect_ids [Array<Integer>] Aspects this stream is responsible for
  # @opt max_time [Integer] Unix timestamp of stream's post ceiling
  # @opt order [String] Order of posts (i.e. 'created_at', 'updated_at')
  # @return [void]
  def initialize(user, inputted_aspect_ids, opts={})
    super(user, opts)
    @inputted_aspect_ids = inputted_aspect_ids
  end

  # Filters aspects given the stream's aspect ids on initialization and the user.
  # Will disclude aspects from inputted aspect ids if user is not associated with their
  # target aspects.
  #
  # @return [ActiveRecord::Association<Aspect>] Filtered aspects given the stream's user
  def aspects
    @aspects ||= lambda do
      a = user.aspects
      a = a.where(:id => @inputted_aspect_ids) if @inputted_aspect_ids.any?
      a
    end.call
  end

  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    # NOTE(this should be something like Post.all_for_stream(@user, aspect_ids, {}) that calls visible_shareables
    @posts ||= user.visible_shareables(Post, :all_aspects? => for_all_aspects?,
                                             :by_members_of => aspect_ids,
                                             :type => TYPES_OF_POST_IN_STREAM,
                                             :order => "#{order} DESC",
                                             :max_time => max_time
                   )
  end

  # @return [ActiveRecord::Association<Person>] AR association of people within stream's given aspects
  def people
    @people ||= Person.unique_from_aspects(aspect_ids, user).includes(:profile)
  end

  # @return [String] URL
  def link(opts={})
    Rails.application.routes.url_helpers.aspects_path(opts)
  end

  # The first aspect in #aspects, given the stream is not for all aspects, or #aspects size is 1
  # @note aspects.first is used for mobile. NOTE(this is a hack and should be fixed)
  # @return [Aspect,Symbol]
  def aspect
    if !for_all_aspects? || aspects.size == 1
      aspects.first
    end
  end

  # The title that will display at the top of the stream's
  # publisher box.
  #
  # @return [String]
  def title
    if self.for_all_aspects?
      I18n.t('streams.aspects.title')
    else
      self.aspects.to_sentence
    end
  end

  # Determine whether or not the stream is displaying across
  # all of the user's aspects.
  #
  # @return [Boolean]
  def for_all_aspects?
    @all_aspects ||= aspects.size == user.aspects.size
  end

  # This is perfomance optimization, as everyone in your aspect stream you have
  # a contact.
  #
  # @param post [Post]
  # @return [Boolean]
  def can_comment?(post)
    true
  end

  private

  def aspect_ids
    @aspect_ids ||= aspects.map(&:id)
  end
end

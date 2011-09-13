#   Copyright (c) 2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AspectStream

  attr_reader :max_time, :order

  # @param user [User]
  # @param inputted_aspect_ids [Array<Integer>] Ids of aspects for given stream
  # @param aspect_ids [Array<Integer>] Aspects this stream is responsible for
  # @opt max_time [Integer] Unix timestamp of stream's post ceiling
  # @opt order [String] Order of posts (i.e. 'created_at', 'updated_at')
  # @return [void]
  def initialize(user, inputted_aspect_ids, opts={})
    @user = user
    @inputted_aspect_ids = inputted_aspect_ids
    @max_time = opts[:max_time]
    @order = opts[:order]
  end

  # Filters aspects given the stream's aspect ids on initialization and the user.
  # Will disclude aspects from inputted aspect ids if user is not associated with their
  # target aspects.
  #
  # @return [ActiveRecord::Association<Aspect>] Filtered aspects given the stream's user
  def aspects
    @aspects ||= lambda do
      a = @user.aspects
      a = a.where(:id => @inputted_aspect_ids) if @inputted_aspect_ids.length > 0
      a
    end.call
  end

  # Maps ids into an array from #aspects
  #
  # @return [Array<Integer>] Aspect ids
  def aspect_ids
    @aspect_ids ||= aspects.map { |a| a.id }
  end

  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    # NOTE(this should be something like Post.all_for_stream(@user, aspect_ids, {}) that calls visible_posts
    @posts ||= @user.visible_posts(:by_members_of => aspect_ids,
                                   :type => ['StatusMessage', 'Reshare', 'ActivityStreams::Photo'],
                                   :order => "#{@order} DESC",
                                   :max_time => @max_time
                   ).includes(:mentions => {:person => :profile}, :author => :profile)
  end

  # @return [ActiveRecord::Association<Person>] AR association of people within stream's given aspects
  def people
    @people ||= Person.all_from_aspects(aspect_ids, @user)
  end

  # The first aspect in #aspects, given the stream is not for all aspects, or #aspects size is 1
  # @note aspects.first is used for mobile. NOTE(this is a hack and should be fixed)
  # @return [Aspect,Symbol]
  def aspect
    if !for_all_aspects? || aspects.size == 1
      aspects.first
    end
  end

  # Determine whether or not the stream is displaying across
  # all of the user's aspects.
  #
  # @return [Boolean]
  def for_all_aspects?
    @all_aspects ||= aspect_ids.length == @user.aspects.size
  end
end

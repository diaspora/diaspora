#   Copyright (c) 2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AspectStream

  attr_reader :max_time, :order

  # @param user [User]
  # @param aspect_ids [Array<Integer>] Aspects this stream is responsible for
  def initialize(user, inputted_aspect_ids, opts={})
    @user = user
    @inputted_aspect_ids = inputted_aspect_ids

    @max_time = opts[:max_time].to_i
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
    @aspects
  end

  # Maps ids into an array from #aspects
  #
  # @return [Array<Integer>] Aspect ids
  def aspect_ids
    @aspect_ids ||= aspects.map { |a| a.id }
  end

  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    # NOTE(this should be something like User.aspect_post(@aspect_ids, {}) that calls visible_posts
    @posts ||= @user.visible_posts(:by_members_of => @aspect_ids,
                                   :type => ['StatusMessage','Reshare', 'ActivityStreams::Photo'],
                                   :order => "#{@order} DESC",
                                   :max_time => @max_time
                   ).includes(:mentions => {:person => :profile}, :author => :profile)
  end

  # @return [ActiveRecord::Association<Person>] AR association of people within stream's given aspects
  def people
    # NOTE(this should call a method in Person
    @people ||= Person.joins(:contacts => :aspect_memberships).
                                   where(:contacts => {:user_id => @user.id},
                                         :aspect_memberships => {:aspect_id => @aspect_ids}).
                                   select("DISTINCT people.*").includes(:profile)
  end

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

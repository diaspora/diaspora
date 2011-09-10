#   Copyright (c) 2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AspectStream

  attr_reader :aspects, :aspect_ids, :max_time, :order

  # @param user [User]
  # @param aspect_ids [Array<Integer>] Aspects this stream is responsible for
  def initialize(user, aspect_ids, opts={})
    @user = user
    @aspects = user.aspects
    @aspects = @aspects.where(:id => aspect_ids) if aspect_ids.present?
    @aspect_ids = self.aspect_ids

    # ugly hack for now
    @max_time = opts[:max_time].to_i
    @order = opts[:order]
  end

  # @return [Array<Integer>]
  def aspect_ids
    @aspect_ids ||= @aspects.map { |a| a.id }
  end

  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    @posts ||= @user.visible_posts(:by_members_of => @aspect_ids,
                                   :type => ['StatusMessage','Reshare', 'ActivityStreams::Photo'],
                                   :order => @order + ' DESC',
                                   :max_time => @max_time
                   ).includes(:mentions => {:person => :profile}, :author => :profile)
  end

  # @return [ActiveRecord::Association<Person>] AR association of people within stream's given aspects
  def people
    @people ||= Person.joins(:contacts => :aspect_memberships).
                                   where(:contacts => {:user_id => @user.id},
                                         :aspect_memberships => {:aspect_id => @aspect_ids}).
                                   select("DISTINCT people.*").includes(:profile)
  end

  # @note aspects.first is used for mobile.
  #       The :all is currently used for view switching logic
  # @return [Aspect,Symbol]
  def aspect
    for_all_aspects? ? :all : @aspects.first
  end

  # Determine whether or not the stream is displaying across
  # all of the user's aspects.
  #
  # @return [Boolean]
  def for_all_aspects?
    @aspect_ids.length == @aspects.length
  end

end

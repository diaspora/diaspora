# frozen_string_literal: true

module NotificationsHelper
  include PeopleHelper
  include PostsHelper

  def object_link(note, actors_html)
    target_type = note.popup_translation_key
    opts = {actors: actors_html, count: note.actors.size}

    if note.respond_to?(:linked_object)
      if note.linked_object.nil? && note.respond_to?(:deleted_translation_key)
        target_type = note.deleted_translation_key
      elsif note.is_a?(Notifications::Mentioned)
        opts.merge!(opts_for_mentioned(note.linked_object))
      elsif %w(Notifications::CommentOnPost Notifications::AlsoCommented Notifications::Reshared Notifications::Liked)
            .include?(note.type)
        opts.merge!(opts_for_post(note.linked_object))
      end
    end
    translation(target_type, opts)
  end

  def translation(target_type, opts = {})
    t("#{target_type}", opts).html_safe
  end

  def opts_for_post(post)
    {
      post_author: html_escape(post.author_name),
      post_link:   link_to(post_page_title(post),
                           post_path(post),
                           data:  {ref: post.id},
                           class: "hard_object_link").html_safe
    }
  end

  def opts_for_mentioned(mentioned)
    post = mentioned.instance_of?(Comment) ? mentioned.parent : mentioned
    {
      post_link: link_to(post_page_title(post), post_path(post)).html_safe
    }.tap {|opts|
      opts[:comment_path] = post_path(post, anchor: mentioned.guid).html_safe if mentioned.instance_of?(Comment)
    }
  end

  def notification_people_link(note, people=nil)
    actors =people || note.actors
    number_of_actors = actors.size
    sentence_translations = {:two_words_connector => " #{t('notifications.index.and')} ", :last_word_connector => ", #{t('notifications.index.and')} " }
    actor_links = actors.collect{ |person|
      person_link(person, :class => 'hovercardable')
    }

    if number_of_actors < 4
      message = actor_links.to_sentence(sentence_translations)
    else
      first, second, third, *others = actor_links
      others_sentence = others.to_sentence(sentence_translations)
      if others.count == 1
        others_sentence = " #{t('notifications.index.and')} " + others_sentence
      end
      message = "#{first}, #{second}, #{third},"
      message += "<a class='more' href='#'> #{t('notifications.index.and_others', :count =>(number_of_actors - 3))}</a>"
      message += "<span class='hidden'> #{others_sentence} </span>"
    end
    message.html_safe
  end

  def notification_message_for(note)
    object_link(note, notification_people_link(note))
  end

  def the_day(date)
    date.split('-')[2].to_i
  end

  def the_month(date)
    I18n.l(Date.strptime(date, '%Y-%m-%d'), :format => '%B')
  end

  def the_year(date)
    date.split('-')[0].to_i
  end

  def locale_date(date)
    I18n.l(Date.strptime(date, '%Y-%m-%d'), :format => I18n.t('date.formats.fullmonth_day'))
  end

  def display_year?(year, date)
    unless year
      Date.current.year != the_year(date)
    else
      year != the_year(date)
    end
  end
end

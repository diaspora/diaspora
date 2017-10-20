# frozen_string_literal: true

module TagsHelper
  def looking_for_tag_link
    return if search_query.include?('@') || normalize_tag_name(search_query).blank?
    content_tag('small') do
      t('people.index.looking_for', tag_link: tag_link(search_query)).html_safe
    end
  end

  def normalize_tag_name(tag)
    ActsAsTaggableOn::Tag.normalize(tag.to_s)
  end

  def tag_link(tag)
    link_to("##{tag}", tag_path(name: normalize_tag_name(tag)))
  end
end

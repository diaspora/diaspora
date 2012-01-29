module TagsHelper
  def looking_for_tag_link
    return if search_query.include?('@') || normalized_tag_name.blank?
    content_tag('h4') do 
      content_tag('small') do
        t('people.index.looking_for', :tag_link => tag_link).html_safe
      end
    end
  end

  def normalized_tag_name
    ActsAsTaggableOn::Tag.normalize(search_query)
  end

  def tag_link
    tag = normalized_tag_name
    link_to("##{tag}", tag_path(:name => tag))
  end
end

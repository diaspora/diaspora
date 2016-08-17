#   Copyright (c) 2016, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class TagPresenter < BasePresenter
  def title
    @presentable.display_tag_name
  end

  def metas_attributes
    [
      { name:     'keywords'    , content: tag_name    },
      { name:     'description' , content: description },
      { property: 'og:title'    , content: title       },
      { property: 'og:url'      , content: url         }
    ]
  end

  private

  def description
    I18n.t("tags.show.description", {"tag": tag_name})
  end

  def url
    tag_url tag_name
  end
end

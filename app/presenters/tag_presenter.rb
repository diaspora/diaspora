#   Copyright (c) 2016, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class TagPresenter < BasePresenter
  def title
    @presentable.display_tag_name
  end

  def metas_attributes
    {
      keywords:       { name:     'keywords'      ,  content: tag_name    },
      description:    { name:     'description'   ,  content: description },
      og_description: { property: 'og:description',  content: description },
      og_title:       { property: 'og:title'      ,  content: title       },
      og_url:         { property: 'og:url'        ,  content: url         }
    }
  end

  private

  def description
    I18n.t("streams.tags.title", {"tags": tag_name})
  end

  def url
    tag_url tag_name
  end
end

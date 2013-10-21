
module Diaspora::Backbone

  MIME_TYPE = 'application/vnd.diaspora.backbone+json'

  Mime::Type.register MIME_TYPE, :backbone

  class Constraint
    def matches?(request)
      accept = request.headers['Accept']
      (accept && accept == MIME_TYPE)
    end
  end
end

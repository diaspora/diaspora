
module Diaspora::Backbone
  class Constraint
    def matches?(request)
      accept = request.headers['Accept']
      (accept && accept == "application/vnd.diaspora.backbone+json")
    end
  end
end


class Diaspora::Backbone::Responder < ActionController::Responder
  def to_backbone
    hash = if resource.is_a?(Hash) || resource.is_a?(Array)
              resource
            elsif resource.respond_to?(:full_hash)  # presenter
              resource.full_hash
            elsif resource.respond_to?(:base_hash)  # minimal presenter
              resource.base_hash
            else
              resource.to_h
            end

    render options.merge(json: hash, content_type: Mime::JSON)
  end
end

class User
  alias_method :share_with_original, :share_with

  def share_with(*args)
    inlined_jobs do
      share_with_original(*args)
    end
  end

  def add_contact_to_aspect(contact, aspect)
    return if AspectMembership.exists?(contact_id: contact.id, aspect_id: aspect.id)
    contact.aspect_memberships.create!(aspect: aspect)
  end

  def post(class_name, opts = {})
    inlined_jobs do
      aspects = self.aspects_from_ids(opts[:to])

      p = build_post(class_name, opts)
      p.aspects = aspects
      if p.save!
        self.aspects.reload

        dispatch_opts = {
          url: Rails.application.routes.url_helpers.post_url(
            p,
            host: AppConfig.pod_uri.to_s
          ),
          to:  opts[:to]}
        dispatch_opts.merge!(:additional_subscribers => p.root.author) if class_name == :reshare
        dispatch_post(p, dispatch_opts)
      end
      unless opts[:created_at]
        p.created_at = Time.now - 1
        p.save
      end
      p
    end
  end
end

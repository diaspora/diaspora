class User
  alias_method :share_with_original, :share_with

  def share_with(*args)
    inlined_jobs do
      share_with_original(*args)
    end
  end

  def post(class_name, opts = {})
    inlined_jobs do
      aspects = self.aspects_from_ids(opts[:to])

      p = build_post(class_name, opts)
      p.aspects = aspects
      if p.save!
        self.aspects.reload

        add_to_streams(p, aspects)
        dispatch_opts = {url: Rails.application.routes.url_helpers.post_url(p), to: opts[:to]}
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

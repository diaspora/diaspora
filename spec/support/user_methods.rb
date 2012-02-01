class User
  include Rails.application.routes.url_helpers
  def default_url_options
    {:host => AppConfig[:pod_url]}
  end

  alias_method :share_with_original, :share_with

  def share_with(*args)
    fantasy_resque do
      share_with_original(*args)
    end
  end

  def post(class_name, opts = {})
    fantasy_resque do
      p = build_post(class_name, opts)
      if p.save!
        self.aspects.reload

        aspects = self.aspects_from_ids(opts[:to])
        add_to_streams(p, aspects)
        dispatch_opts = {:url => post_url(p), :to => opts[:to]}
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

  def like(positive, options ={})
    fantasy_resque do
      l = build_like(options.merge(:positive => positive))
      if l.save!
        Postzord::Dispatcher.build(self, l).post
      end
      l
    end
  end

  def post_at_time(time)
    to_aspect = self.aspects.length == 1 ? self.aspects.first : self.aspects.where(:name => "generic")
    p = self.post(:status_message, :text => 'hi', :to => to_aspect)
    p.created_at = time
    p.save!
  end
end

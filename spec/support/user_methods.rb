class User

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
        dispatch_post(p, :to => opts[:to])
      end
      unless opts[:created_at]
        p.created_at = Time.now - 1
        p.save
      end
      p
    end
  end

  def comment(text, options = {})
    fantasy_resque do
      c = build_comment(options.merge(:text => text))
      if c.save!
        Postzord::Dispatch.new(self, c).post
      end
      c
    end
  end

  def like(positive, options ={})
    fantasy_resque do
      l = build_like(options.merge(:positive => positive))
      if l.save!
        Postzord::Dispatch.new(self, l).post
      end
      l
    end
  end

  def post_at_time(time)
    p = self.post(:status_message, :text => 'hi', :to => self.aspects.first)
    p.created_at = time
    p.save!
  end
end

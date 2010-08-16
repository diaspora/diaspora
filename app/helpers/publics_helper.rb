module PublicsHelper
  def subscribe(opts = {})
    subscriber = Subscriber.first(:url => opts[:callback], :topic => opts[:topic])
    subscriber ||= Subscriber.new(:url => opts[:callback], :topic => opts[:topic])

    if subscriber.save

      if opts[:verify] == 'sync'
        204
      elsif opts[:verify] == 'async'
        202
      end
    else 
      400
    end
  end

  def terse_url(full_url)
    terse = full_url.gsub(/https?:\/\//, '')
    terse.gsub!(/www\./, '')
    terse = terse.chop! if terse[-1, 1] == '/'
    terse
  end
end

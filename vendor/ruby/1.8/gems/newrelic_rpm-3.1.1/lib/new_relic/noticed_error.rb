# This class encapsulates an error that was noticed by New Relic in a managed app.
class NewRelic::NoticedError
  extend NewRelic::CollectionHelper
  attr_accessor :path, :timestamp, :params, :exception_class, :message

  def initialize(path, data, exception, timestamp = Time.now)
    self.path = path
    self.params = NewRelic::NoticedError.normalize_params(data)

    self.exception_class = exception.is_a?(Exception) ? exception.class.name : 'Error'

    if exception.respond_to?('original_exception')
      self.message = exception.original_exception.message.to_s
    else
      self.message = (exception || '<no message>').to_s
    end

    # clamp long messages to 4k so that we don't send a lot of
    # overhead across the wire
    self.message = self.message[0..4095] if self.message.length > 4096

    self.timestamp = timestamp
  end
end

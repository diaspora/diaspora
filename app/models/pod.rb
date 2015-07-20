class Pod < ActiveRecord::Base
  def self.find_or_create_by(opts) # Rename this method to not override an AR method
    u = URI.parse(opts.fetch(:url))
    pod = self.find_or_initialize_by(host: u.host)
    unless pod.persisted?
      pod.ssl = (u.scheme == 'https')? true : false
      pod.save
    end
    pod
  end
end

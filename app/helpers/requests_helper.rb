module RequestsHelper
  def diaspora_url(identifier)
    if identifier.include? '@'
      f = Redfinger.finger(identifier)
      identifier = f.links.each{|x|  return x.href if x.rel =='http://joindiaspora.com/seed_location'}
    end
    identifier
  end

end

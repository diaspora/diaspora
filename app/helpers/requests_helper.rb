module RequestsHelper
  def diaspora_url(identifier)
    if identifier.include? '@'
      
      begin
        f = Redfinger.finger(identifier)
        good_links = f.links.map{|x|  return x.href if x.rel =='http://joindiaspora.com/seed_location'}
        identifier = good_links.first unless good_links.first.nil?
      rescue
        
      end
    end

    identifier
  end
end

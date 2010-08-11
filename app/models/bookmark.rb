class Bookmark < Post
  
  xml_accessor :link
  xml_accessor :title
  
  key :link, String
  key :title, String
  
  
  validates_presence_of :link  

  validates_format_of :link, :with =>
    /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix

  def to_activity
        <<-XML
  <entry>
  <activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb>
  <title>#{self.title}</title>
  <link rel="alternate" type="text/html" href="#{User.owner.url}bookmarks/#{self.id}"/>
  <link rel="related" type="text/html" href="#{self.link}"/>
  <id>#{User.owner.url}bookmarks/#{self.id}</id>
  <published>#{self.created_at.xmlschema}</published>
  <updated>#{self.updated_at.xmlschema}</updated>
  </entry>
        XML
  end
  
  def self.instantiate params
    params[:link] = clean_link(params[:link])
    create params
  end

  protected
  def self.clean_link link
    if link
      link = 'http://' + link unless link.match('https?://')
      link = link + '/' if link[-1,1] != '/'
      link
    end
  end
end

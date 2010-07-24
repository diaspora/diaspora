class Blog < Post
  
  xml_accessor :title
  xml_accessor :body

  
  key :title, String
  key :body, String
  
  validates_presence_of :title, :body
  
  def to_activity
          <<-XML
  <entry>
  <activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb>
  <title>#{self.title}</title>
  <content>#{self.body}</content>
  <link rel="alternate" type="text/html" href="#{User.owner.url}blogs/#{self.id}"/>
  <id>#{User.owner.url}blogs/#{self.id}</id>
  <published>#{self.created_at.xmlschema}</published>
  <updated>#{self.updated_at.xmlschema}</updated>
  </entry>
          XML
  end
  
end

class SpecDoc
  def initialize(response)
    @html = Nokogiri::HTML(response.body)
  end

  def method_missing(method, *args)
    @html.send method, *args
  end

  def has_content?(string)
    escaped = string.gsub("'", "\\'")
    @html.xpath("//*[contains(text(), '#{escaped}')]").any?
  end
  def has_no_content?(string)
    ! has_content?(string)
  end

  def has_link?(text)
    @html.xpath("//a[text()='#{text}']").any?
  end
end

def doc
  SpecDoc.new response
end

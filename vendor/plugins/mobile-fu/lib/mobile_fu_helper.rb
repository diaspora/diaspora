module MobileFuHelper
  ACCEPTABLE_TYPES = [:mobile, :basic]

  def mobile_xhtml_doctype(type = :mobile, version = '1.0')
    raise Exception.new("MobileFu: XHTML DOCTYPE type must either be ':mobile' or ':basic'") unless ACCEPTABLE_TYPES.include?(type)
    raise Exception.new("MobileFu: XHTML DOCTYPE version must be in the format of '1.0' or '1.1', etc.") unless version.include?('.')

    doc_type = "<?xml version=\"1.0\" charset=\"UTF-8\" ?>\n"
    doc_type += "<!DOCTYPE html PUBLIC "
    doc_type += case type
                when :mobile
                  "\"-//WAPFORUM//DTD XHTML Mobile #{version}//EN\" \"http://www.openmobilealliance.org/tech/DTD/xhtml-mobile#{version.gsub('.','')}.dtd\">"
                when :basic
                  "\"-//W3C//DTD XHTML Basic #{version}//EN\" \"http://www.w3.org/TR/xhtml-basic/xhtml-basic#{version.gsub('.','')}.dtd\">"
                end
    doc_type
  end

  def js_enabled_mobile_device?
    is_device?('iphone') || is_device?('ipod') || is_device?('ipad') || is_device?('mobileexplorer') || is_device?('android')
  end
end

ActionView::Base.send(:include, MobileFuHelper)
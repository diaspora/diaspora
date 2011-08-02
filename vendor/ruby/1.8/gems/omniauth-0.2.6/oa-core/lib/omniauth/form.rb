require 'omniauth/core'

module OmniAuth
  class Form
    DEFAULT_CSS = <<-CSS
    body {
      background: #ccc;
      font-family: "Lucida Grande", "Lucida Sans", Helvetica, Arial, sans-serif;
    }

    h1 {
      text-align: center;
      margin: 30px auto 0px;
      font-size: 18px;
      padding: 10px 10px 15px;
      background: #555;
      color: white;
      width: 320px;
      border: 10px solid #444;
      border-bottom: 0;
      -moz-border-radius-topleft: 10px;
      -moz-border-radius-topright: 10px;
      -webkit-border-top-left-radius: 10px;
      -webkit-border-top-right-radius: 10px;
      border-top-left-radius: 10px;
      border-top-right-radius: 10px;
    }

    h1, form {
      -moz-box-shadow: 2px 2px 7px rgba(0,0,0,0.3);
      -webkit-box-shadow: 2px 2px 7px rgba(0,0,0,0.3);
    }

    form {
      background: white;
      border: 10px solid #eee;
      border-top: 0;
      padding: 20px;
      margin: 0px auto 40px;
      width: 300px;
      -moz-border-radius-bottomleft: 10px;
      -moz-border-radius-bottomright: 10px;
      -webkit-border-bottom-left-radius: 10px;
      -webkit-border-bottom-right-radius: 10px;
      border-bottom-left-radius: 10px;
      border-bottom-right-radius: 10px;
    }

    label {
      display: block;
      font-weight: bold;
      margin-bottom: 5px;
    }

    input {
      font-size: 18px;
      padding: 4px 8px;
      display: block;
      margin-bottom: 10px;
      width: 280px;
    }

    input#identifier, input#openid_url {
      background: url(http://openid.net/login-bg.gif) no-repeat;
      background-position: 0 50%;
      padding-left: 18px;
    }

    button {
      font-size: 22px;
      padding: 4px 8px;
      display: block;
      margin: 20px auto 0;
    }

    fieldset {
      border: 1px solid #ccc;
      border-left: 0;
      border-right: 0;
      padding: 10px 0;
    }

    fieldset input {
      width: 260px;
      font-size: 16px;
    }
    CSS

    attr_accessor :options

    def initialize(options = {})
      options[:title] ||= "Authentication Info Required"
      options[:header_info] ||= ""
      self.options = options

      @html = ""
      header(options[:title],options[:header_info])
    end

    def self.build(title=nil,&block)
      form = OmniAuth::Form.new(title)
      form.instance_eval(&block)
    end

    def label_field(text, target)
      @html << "\n<label for='#{target}'>#{text}:</label>"
      self
    end

    def input_field(type, name)
      @html << "\n<input type='#{type}' id='#{name}' name='#{name}'/>"
      self
    end

    def text_field(label, name)
      label_field(label, name)
      input_field('text', name)
      self
    end

    def password_field(label, name)
      label_field(label, name)
      input_field('password', name)
      self
    end

    def button(text)
      @html << "\n<button type='submit'>#{text}</button>"
    end

    def html(html)
      @html << html
    end

    def fieldset(legend, options = {}, &block)
      @html << "\n<fieldset#{" style='#{options[:style]}'" if options[:style]}#{" id='#{options[:id]}'" if options[:id]}>\n  <legend>#{legend}</legend>\n"
      self.instance_eval &block
      @html << "\n</fieldset>"
      self
    end

    def header(title,header_info)
      @html << <<-HTML
      <!DOCTYPE html>
      <html>
      <head>
        <title>#{title}</title>
        #{css}
        #{header_info}
      </head>
      <body>
      <h1>#{title}</h1>
      <form method='post' #{"action='#{options[:url]}' " if options[:url]}noValidate='noValidate'>
      HTML
      self
    end

    def footer
      return self if @footer
      @html << <<-HTML
      <button type='submit'>Connect</button>
      </form>
      </body>
      </html>
      HTML
      @footer = true
      self
    end

    def to_html
      footer
      @html
    end

    def to_response
      footer
      Rack::Response.new(@html).finish
    end

    protected

    def css
      "\n<style type='text/css'>#{OmniAuth.config.form_css}</style>"
    end
  end
end

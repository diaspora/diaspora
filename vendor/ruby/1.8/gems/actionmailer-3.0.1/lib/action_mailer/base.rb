require 'mail'
require 'action_mailer/tmail_compat'
require 'action_mailer/collector'
require 'active_support/core_ext/array/wrap'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/proc'
require 'action_mailer/log_subscriber'

module ActionMailer #:nodoc:
  # Action Mailer allows you to send email from your application using a mailer model and views.
  #
  # = Mailer Models
  #
  # To use Action Mailer, you need to create a mailer model.
  #
  #   $ rails generate mailer Notifier
  #
  # The generated model inherits from <tt>ActionMailer::Base</tt>. Emails are defined by creating methods
  # within the model which are then used to set variables to be used in the mail template, to
  # change options on the mail, or to add attachments.
  #
  # Examples:
  #
  #  class Notifier < ActionMailer::Base
  #    default :from => 'no-reply@example.com',
  #            :return_path => 'system@example.com'
  #
  #    def welcome(recipient)
  #      @account = recipient
  #      mail(:to => recipient.email_address_with_name,
  #           :bcc => ["bcc@example.com", "Order Watcher <watcher@example.com>"])
  #      end
  #    end
  #
  # Within the mailer method, you have access to the following methods:
  #
  # * <tt>attachments[]=</tt> - Allows you to add attachments to your email in an intuitive
  #   manner; <tt>attachments['filename.png'] = File.read('path/to/filename.png')</tt>
  #
  # * <tt>attachments.inline[]=</tt> - Allows you to add an inline attachment to your email
  #   in the same manner as <tt>attachments[]=</tt>
  #
  # * <tt>headers[]=</tt> - Allows you to specify any header field in your email such
  #   as <tt>headers['X-No-Spam'] = 'True'</tt>. Note, while most fields like <tt>To:</tt>
  #   <tt>From:</tt> can only appear once in an email header, other fields like <tt>X-Anything</tt>
  #   can appear multiple times. If you want to change a field that can appear multiple times,
  #   you need to set it to nil first so that Mail knows you are replacing it and not adding
  #   another field of the same name.
  #
  # * <tt>headers(hash)</tt> - Allows you to specify multiple headers in your email such
  #   as <tt>headers({'X-No-Spam' => 'True', 'In-Reply-To' => '1234@message.id'})</tt>
  #
  # * <tt>mail</tt> - Allows you to specify email to be sent.
  #
  # The hash passed to the mail method allows you to specify any header that a Mail::Message
  # will accept (any valid Email header including optional fields).
  #
  # The mail method, if not passed a block, will inspect your views and send all the views with
  # the same name as the method, so the above action would send the +welcome.text.plain.erb+ view
  # file as well as the +welcome.text.html.erb+ view file in a +multipart/alternative+ email.
  #
  # If you want to explicitly render only certain templates, pass a block:
  #
  #   mail(:to => user.email) do |format|
  #     format.text
  #     format.html
  #   end
  #
  # The block syntax is also useful in providing information specific to a part:
  #
  #   mail(:to => user.email) do |format|
  #     format.text(:content_transfer_encoding => "base64")
  #     format.html
  #   end
  #
  # Or even to render a special view:
  #
  #   mail(:to => user.email) do |format|
  #     format.text
  #     format.html { render "some_other_template" }
  #   end
  #
  # = Mailer views
  #
  # Like Action Controller, each mailer class has a corresponding view directory in which each
  # method of the class looks for a template with its name.
  #
  # To define a template to be used with a mailing, create an <tt>.erb</tt> file with the same
  # name as the method in your mailer model. For example, in the mailer defined above, the template at
  # <tt>app/views/notifier/signup_notification.text.plain.erb</tt> would be used to generate the email.
  #
  # Variables defined in the model are accessible as instance variables in the view.
  #
  # Emails by default are sent in plain text, so a sample view for our model example might look like this:
  #
  #   Hi <%= @account.name %>,
  #   Thanks for joining our service! Please check back often.
  #
  # You can even use Action Pack helpers in these views. For example:
  #
  #   You got a new note!
  #   <%= truncate(@note.body, 25) %>
  #
  # If you need to access the subject, from or the recipients in the view, you can do that through message object:
  #
  #   You got a new note from <%= message.from %>!
  #   <%= truncate(@note.body, 25) %>
  #
  #
  # = Generating URLs
  #
  # URLs can be generated in mailer views using <tt>url_for</tt> or named routes. Unlike controllers from
  # Action Pack, the mailer instance doesn't have any context about the incoming request, so you'll need
  # to provide all of the details needed to generate a URL.
  #
  # When using <tt>url_for</tt> you'll need to provide the <tt>:host</tt>, <tt>:controller</tt>, and <tt>:action</tt>:
  #
  #   <%= url_for(:host => "example.com", :controller => "welcome", :action => "greeting") %>
  #
  # When using named routes you only need to supply the <tt>:host</tt>:
  #
  #   <%= users_url(:host => "example.com") %>
  #
  # You want to avoid using the <tt>name_of_route_path</tt> form of named routes because it doesn't
  # make sense to generate relative URLs in email messages.
  #
  # It is also possible to set a default host that will be used in all mailers by setting the <tt>:host</tt>
  # option as a configuration option in <tt>config/application.rb</tt>:
  #
  #   config.action_mailer.default_url_options = { :host => "example.com" }
  #
  # Setting <tt>ActionMailer::Base.default_url_options</tt> directly is now deprecated, use the configuration
  # option mentioned above to set the default host.
  #
  # If you do decide to set a default <tt>:host</tt> for your mailers you want to use the
  # <tt>:only_path => false</tt> option when using <tt>url_for</tt>. This will ensure that absolute URLs are
  # generated because the <tt>url_for</tt> view helper will, by default, generate relative URLs when a
  # <tt>:host</tt> option isn't explicitly provided.
  #
  # = Sending mail
  #
  # Once a mailer action and template are defined, you can deliver your message or create it and save it
  # for delivery later:
  #
  #   Notifier.welcome(david).deliver # sends the email
  #   mail = Notifier.welcome(david)  # => a Mail::Message object
  #   mail.deliver                    # sends the email
  #
  # You never instantiate your mailer class. Rather, you just call the method you defined on the class itself.
  #
  # = Multipart Emails
  #
  # Multipart messages can also be used implicitly because Action Mailer will automatically
  # detect and use multipart templates, where each template is named after the name of the action, followed
  # by the content type. Each such detected template will be added as separate part to the message.
  #
  # For example, if the following templates exist:
  # * signup_notification.text.plain.erb
  # * signup_notification.text.html.erb
  # * signup_notification.text.xml.builder
  # * signup_notification.text.yaml.erb
  #
  # Each would be rendered and added as a separate part to the message, with the corresponding content
  # type. The content type for the entire message is automatically set to <tt>multipart/alternative</tt>,
  # which indicates that the email contains multiple different representations of the same email
  # body. The same instance variables defined in the action are passed to all email templates.
  #
  # Implicit template rendering is not performed if any attachments or parts have been added to the email.
  # This means that you'll have to manually add each part to the email and set the content type of the email
  # to <tt>multipart/alternative</tt>.
  #
  # = Attachments
  #
  # Sending attachment in emails is easy:
  #
  #   class ApplicationMailer < ActionMailer::Base
  #     def welcome(recipient)
  #       attachments['free_book.pdf'] = File.read('path/to/file.pdf')
  #       mail(:to => recipient, :subject => "New account information")
  #     end
  #   end
  #
  # Which will (if it had both a <tt>welcome.text.plain.erb</tt> and <tt>welcome.text.html.erb</tt>
  # template in the view directory), send a complete <tt>multipart/mixed</tt> email with two parts,
  # the first part being a <tt>multipart/alternative</tt> with the text and HTML email parts inside,
  # and the second being a <tt>application/pdf</tt> with a Base64 encoded copy of the file.pdf book
  # with the filename +free_book.pdf+.
  #
  # = Inline Attachments
  #
  # You can also specify that a file should be displayed inline with other HTML. This is useful
  # if you want to display a corporate logo or a photo.
  #
  #   class ApplicationMailer < ActionMailer::Base
  #     def welcome(recipient)
  #       attachments.inline['photo.png'] = File.read('path/to/photo.png')
  #       mail(:to => recipient, :subject => "Here is what we look like")
  #     end
  #   end
  #
  # And then to reference the image in the view, you create a <tt>welcome.html.erb</tt> file and
  # make a call to +image_tag+ passing in the attachment you want to display and then call
  # +url+ on the attachment to get the relative content id path for the image source:
  #
  #   <h1>Please Don't Cringe</h1>
  #
  #   <%= image_tag attachments['photo.png'].url -%>
  #
  # As we are using Action View's +image_tag+ method, you can pass in any other options you want:
  #
  #   <h1>Please Don't Cringe</h1>
  #
  #   <%= image_tag attachments['photo.png'].url, :alt => 'Our Photo', :class => 'photo' -%>
  #
  # = Observing and Intercepting Mails
  #
  # Action Mailer provides hooks into the Mail observer and interceptor methods.  These allow you to
  # register objects that are called during the mail delivery life cycle.
  #
  # An observer object must implement the <tt>:delivered_email(message)</tt> method which will be
  # called once for every email sent after the email has been sent.
  #
  # An interceptor object must implement the <tt>:delivering_email(message)</tt> method which will be
  # called before the email is sent, allowing you to make modifications to the email before it hits
  # the delivery agents.  Your object should make and needed modifications directly to the passed
  # in Mail::Message instance.
  #
  # = Default Hash
  #
  # Action Mailer provides some intelligent defaults for your emails, these are usually specified in a
  # default method inside the class definition:
  #
  #   class Notifier < ActionMailer::Base
  #     default :sender => 'system@example.com'
  #   end
  #
  # You can pass in any header value that a <tt>Mail::Message</tt>, out of the box, <tt>ActionMailer::Base</tt>
  # sets the following:
  #
  # * <tt>:mime_version => "1.0"</tt>
  # * <tt>:charset      => "UTF-8",</tt>
  # * <tt>:content_type => "text/plain",</tt>
  # * <tt>:parts_order  => [ "text/plain", "text/enriched", "text/html" ]</tt>
  #
  # <tt>parts_order</tt> and <tt>charset</tt> are not actually valid <tt>Mail::Message</tt> header fields,
  # but Action Mailer translates them appropriately and sets the correct values.
  #
  # As you can pass in any header, you need to either quote the header as a string, or pass it in as
  # an underscorised symbol, so the following will work:
  #
  #   class Notifier < ActionMailer::Base
  #     default 'Content-Transfer-Encoding' => '7bit',
  #             :content_description => 'This is a description'
  #   end
  #
  # Finally, Action Mailer also supports passing <tt>Proc</tt> objects into the default hash, so you
  # can define methods that evaluate as the message is being generated:
  #
  #   class Notifier < ActionMailer::Base
  #     default 'X-Special-Header' => Proc.new { my_method }
  #
  #     private
  #
  #       def my_method
  #         'some complex call'
  #       end
  #   end
  #
  # Note that the proc is evaluated right at the start of the mail message generation, so if you
  # set something in the defaults using a proc, and then set the same thing inside of your
  # mailer method, it will get over written by the mailer method.
  #
  # = Configuration options
  #
  # These options are specified on the class level, like
  # <tt>ActionMailer::Base.template_root = "/my/templates"</tt>
  #
  # * <tt>default</tt> - You can pass this in at a class level as well as within the class itself as
  #   per the above section.
  #
  # * <tt>logger</tt> - the logger is used for generating information on the mailing run if available.
  #   Can be set to nil for no logging. Compatible with both Ruby's own Logger and Log4r loggers.
  #
  # * <tt>smtp_settings</tt> - Allows detailed configuration for <tt>:smtp</tt> delivery method:
  #   * <tt>:address</tt> - Allows you to use a remote mail server. Just change it from its default
  #     "localhost" setting.
  #   * <tt>:port</tt> - On the off chance that your mail server doesn't run on port 25, you can change it.
  #   * <tt>:domain</tt> - If you need to specify a HELO domain, you can do it here.
  #   * <tt>:user_name</tt> - If your mail server requires authentication, set the username in this setting.
  #   * <tt>:password</tt> - If your mail server requires authentication, set the password in this setting.
  #   * <tt>:authentication</tt> - If your mail server requires authentication, you need to specify the
  #     authentication type here.
  #     This is a symbol and one of <tt>:plain</tt>, <tt>:login</tt>, <tt>:cram_md5</tt>.
  #   * <tt>:enable_starttls_auto</tt> - When set to true, detects if STARTTLS is enabled in your SMTP server
  #     and starts to use it.
  #
  # * <tt>sendmail_settings</tt> - Allows you to override options for the <tt>:sendmail</tt> delivery method.
  #   * <tt>:location</tt> - The location of the sendmail executable. Defaults to <tt>/usr/sbin/sendmail</tt>.
  #   * <tt>:arguments</tt> - The command line arguments. Defaults to <tt>-i -t</tt> with <tt>-f sender@addres</tt>
  #     added automatically before the message is sent.
  #
  # * <tt>file_settings</tt> - Allows you to override options for the <tt>:file</tt> delivery method.
  #   * <tt>:location</tt> - The directory into which emails will be written. Defaults to the application
  #     <tt>tmp/mails</tt>.
  #
  # * <tt>raise_delivery_errors</tt> - Whether or not errors should be raised if the email fails to be delivered.
  #
  # * <tt>delivery_method</tt> - Defines a delivery method. Possible values are <tt>:smtp</tt> (default),
  #   <tt>:sendmail</tt>, <tt>:test</tt>, and <tt>:file</tt>. Or you may provide a custom delivery method
  #   object eg. MyOwnDeliveryMethodClass.new.  See the Mail gem documentation on the interface you need to
  #   implement for a custom delivery agent.
  #
  # * <tt>perform_deliveries</tt> - Determines whether emails are actually sent from Action Mailer when you
  #   call <tt>.deliver</tt> on an mail message or on an Action Mailer method.  This is on by default but can
  #   be turned off to aid in functional testing.
  #
  # * <tt>deliveries</tt> - Keeps an array of all the emails sent out through the Action Mailer with
  #   <tt>delivery_method :test</tt>. Most useful for unit and functional testing.
  #
  # * <tt>default_charset</tt> - This is now deprecated, use the +default+ method above to
  #   set the default +:charset+.
  #
  # * <tt>default_content_type</tt> - This is now deprecated, use the +default+ method above
  #   to set the default +:content_type+.
  #
  # * <tt>default_mime_version</tt> - This is now deprecated, use the +default+ method above
  #   to set the default +:mime_version+.
  #
  # * <tt>default_implicit_parts_order</tt> - This is now deprecated, use the +default+ method above
  #   to set the default +:parts_order+.  Parts Order is used when a message is built implicitly
  #   (i.e. multiple parts are assembled from templates which specify the content type in their
  #   filenames) this variable controls how the parts are ordered.
  class Base < AbstractController::Base
    include DeliveryMethods
    abstract!

    include AbstractController::Logger
    include AbstractController::Rendering
    include AbstractController::Layouts
    include AbstractController::Helpers
    include AbstractController::Translation
    include AbstractController::AssetPaths

    helper  ActionMailer::MailHelper

    include ActionMailer::OldApi
    include ActionMailer::DeprecatedApi

    delegate :register_observer, :to => Mail
    delegate :register_interceptor, :to => Mail

    private_class_method :new #:nodoc:

    class_attribute :default_params
    self.default_params = {
      :mime_version => "1.0",
      :charset      => "UTF-8",
      :content_type => "text/plain",
      :parts_order  => [ "text/plain", "text/enriched", "text/html" ]
    }.freeze

    class << self

      def mailer_name
        @mailer_name ||= name.underscore
      end
      attr_writer :mailer_name
      alias :controller_path :mailer_name

      def default(value = nil)
        self.default_params = default_params.merge(value).freeze if value
        default_params
      end

      # Receives a raw email, parses it into an email object, decodes it,
      # instantiates a new mailer, and passes the email object to the mailer
      # object's +receive+ method. If you want your mailer to be able to
      # process incoming messages, you'll need to implement a +receive+
      # method that accepts the raw email string as a parameter:
      #
      #   class MyMailer < ActionMailer::Base
      #     def receive(mail)
      #       ...
      #     end
      #   end
      def receive(raw_mail)
        ActiveSupport::Notifications.instrument("receive.action_mailer") do |payload|
          mail = Mail.new(raw_mail)
          set_payload_for_mail(payload, mail)
          new.receive(mail)
        end
      end

      # Wraps an email delivery inside of Active Support Notifications instrumentation. This
      # method is actually called by the <tt>Mail::Message</tt> object itself through a callback
      # when you call <tt>:deliver</tt> on the Mail::Message, calling +deliver_mail+ directly
      # and passing a Mail::Message will do nothing except tell the logger you sent the email.
      def deliver_mail(mail) #:nodoc:
        ActiveSupport::Notifications.instrument("deliver.action_mailer") do |payload|
          self.set_payload_for_mail(payload, mail)
          yield # Let Mail do the delivery actions
        end
      end

      def respond_to?(method, *args) #:nodoc:
        super || action_methods.include?(method.to_s)
      end

    protected

      def set_payload_for_mail(payload, mail) #:nodoc:
        payload[:mailer]     = self.name
        payload[:message_id] = mail.message_id
        payload[:subject]    = mail.subject
        payload[:to]         = mail.to
        payload[:from]       = mail.from
        payload[:bcc]        = mail.bcc if mail.bcc.present?
        payload[:cc]         = mail.cc  if mail.cc.present?
        payload[:date]       = mail.date
        payload[:mail]       = mail.encoded
      end

      def method_missing(method, *args) #:nodoc:
        if action_methods.include?(method.to_s)
          new(method, *args).message
        else
          super
        end
      end
    end

    attr_internal :message

    # Instantiate a new mailer object. If +method_name+ is not +nil+, the mailer
    # will be initialized according to the named method. If not, the mailer will
    # remain uninitialized (useful when you only need to invoke the "receive"
    # method, for instance).
    def initialize(method_name=nil, *args)
      super()
      @_message = Mail.new
      process(method_name, *args) if method_name
    end

    def process(*args) #:nodoc:
      lookup_context.skip_default_locale!
      super
    end

    class DeprecatedHeaderProxy < ActiveSupport::BasicObject
      def initialize(message)
        @message = message
      end

      def []=(key, value)
        unless value.is_a?(::String)
          ::ActiveSupport::Deprecation.warn("Using a non-String object for a header's value is deprecated. " \
            "You specified #{value.inspect} (a #{value.class}) for #{key}", caller)

          value = value.to_s
        end

        @message[key] = value
      end

      def headers(hash = {})
        hash.each_pair do |k,v|
          self[k] = v
        end
      end

      def method_missing(meth, *args, &block)
        @message.send(meth, *args, &block)
      end
    end

    # Allows you to pass random and unusual headers to the new +Mail::Message+ object
    # which will add them to itself.
    #
    #   headers['X-Special-Domain-Specific-Header'] = "SecretValue"
    #
    # You can also pass a hash into headers of header field names and values, which
    # will then be set on the Mail::Message object:
    #
    #   headers 'X-Special-Domain-Specific-Header' => "SecretValue",
    #           'In-Reply-To' => incoming.message_id
    #
    # The resulting Mail::Message will have the following in it's header:
    #
    #   X-Special-Domain-Specific-Header: SecretValue
    def headers(args=nil)
      if args
        DeprecatedHeaderProxy.new(@_message).headers(args)
      else
        DeprecatedHeaderProxy.new(@_message)
      end
    end

    # Allows you to add attachments to an email, like so:
    #
    #  mail.attachments['filename.jpg'] = File.read('/path/to/filename.jpg')
    #
    # If you do this, then Mail will take the file name and work out the mime type
    # set the Content-Type, Content-Disposition, Content-Transfer-Encoding and
    # base64 encode the contents of the attachment all for you.
    #
    # You can also specify overrides if you want by passing a hash instead of a string:
    #
    #  mail.attachments['filename.jpg'] = {:mime_type => 'application/x-gzip',
    #                                      :content => File.read('/path/to/filename.jpg')}
    #
    # If you want to use a different encoding than Base64, you can pass an encoding in,
    # but then it is up to you to pass in the content pre-encoded, and don't expect
    # Mail to know how to decode this data:
    #
    #  file_content = SpecialEncode(File.read('/path/to/filename.jpg'))
    #  mail.attachments['filename.jpg'] = {:mime_type => 'application/x-gzip',
    #                                      :encoding => 'SpecialEncoding',
    #                                      :content => file_content }
    #
    # You can also search for specific attachments:
    #
    #  # By Filename
    #  mail.attachments['filename.jpg']   # => Mail::Part object or nil
    #
    #  # or by index
    #  mail.attachments[0]                # => Mail::Part (first attachment)
    #
    def attachments
      @_message.attachments
    end

    # The main method that creates the message and renders the email templates. There are
    # two ways to call this method, with a block, or without a block.
    #
    # Both methods accept a headers hash. This hash allows you to specify the most used headers
    # in an email message, these are:
    #
    # * <tt>:subject</tt> - The subject of the message, if this is omitted, Action Mailer will
    #   ask the Rails I18n class for a translated <tt>:subject</tt> in the scope of
    #   <tt>[:actionmailer, mailer_scope, action_name]</tt> or if this is missing, will translate the
    #   humanized version of the <tt>action_name</tt>
    # * <tt>:to</tt> - Who the message is destined for, can be a string of addresses, or an array
    #   of addresses.
    # * <tt>:from</tt> - Who the message is from
    # * <tt>:cc</tt> - Who you would like to Carbon-Copy on this email, can be a string of addresses,
    #   or an array of addresses.
    # * <tt>:bcc</tt> - Who you would like to Blind-Carbon-Copy on this email, can be a string of
    #   addresses, or an array of addresses.
    # * <tt>:reply_to</tt> - Who to set the Reply-To header of the email to.
    # * <tt>:date</tt> - The date to say the email was sent on.
    #
    # You can set default values for any of the above headers (except :date) by using the <tt>default</tt>
    # class method:
    #
    #  class Notifier < ActionMailer::Base
    #    self.default :from => 'no-reply@test.lindsaar.net',
    #                 :bcc => 'email_logger@test.lindsaar.net',
    #                 :reply_to => 'bounces@test.lindsaar.net'
    #  end
    #
    # If you need other headers not listed above, you can either pass them in
    # as part of the headers hash or use the <tt>headers['name'] = value</tt>
    # method.
    #
    # When a <tt>:return_path</tt> is specified as header, that value will be used as the 'envelope from'
    # address for the Mail message.  Setting this is useful when you want delivery notifications
    # sent to a different address than the one in <tt>:from</tt>.  Mail will actually use the
    # <tt>:return_path</tt> in preference to the <tt>:sender</tt> in preference to the <tt>:from</tt>
    # field for the 'envelope from' value.
    #
    # If you do not pass a block to the +mail+ method, it will find all templates in the
    # view paths using by default the mailer name and the method name that it is being
    # called from, it will then create parts for each of these templates intelligently,
    # making educated guesses on correct content type and sequence, and return a fully
    # prepared Mail::Message ready to call <tt>:deliver</tt> on to send.
    #
    # For example:
    #
    #   class Notifier < ActionMailer::Base
    #     default :from => 'no-reply@test.lindsaar.net',
    #
    #     def welcome
    #       mail(:to => 'mikel@test.lindsaar.net')
    #     end
    #   end
    #
    # Will look for all templates at "app/views/notifier" with name "welcome". However, those
    # can be customized:
    #
    #   mail(:template_path => 'notifications', :template_name => 'another')
    #
    # And now it will look for all templates at "app/views/notifications" with name "another".
    #
    # If you do pass a block, you can render specific templates of your choice:
    #
    #   mail(:to => 'mikel@test.lindsaar.net') do |format|
    #     format.text
    #     format.html
    #   end
    #
    # You can even render text directly without using a template:
    #
    #   mail(:to => 'mikel@test.lindsaar.net') do |format|
    #     format.text { render :text => "Hello Mikel!" }
    #     format.html { render :text => "<h1>Hello Mikel!</h1>" }
    #   end
    #
    # Which will render a <tt>multipart/alternative</tt> email with <tt>text/plain</tt> and
    # <tt>text/html</tt> parts.
    #
    # The block syntax also allows you to customize the part headers if desired:
    #
    #   mail(:to => 'mikel@test.lindsaar.net') do |format|
    #     format.text(:content_transfer_encoding => "base64")
    #     format.html
    #   end
    #
    def mail(headers={}, &block)
      # Guard flag to prevent both the old and the new API from firing
      # Should be removed when old API is removed
      @mail_was_called = true
      m = @_message

      # At the beginning, do not consider class default for parts order neither content_type
      content_type = headers[:content_type]
      parts_order  = headers[:parts_order]

      # Call all the procs (if any)
      default_values = self.class.default.merge(self.class.default) do |k,v|
        v.respond_to?(:call) ? v.bind(self).call : v
      end

      # Handle defaults
      headers = headers.reverse_merge(default_values)
      headers[:subject] ||= default_i18n_subject

      # Apply charset at the beginning so all fields are properly quoted
      m.charset = charset = headers[:charset]

      # Set configure delivery behavior
      wrap_delivery_behavior!(headers.delete(:delivery_method))

      # Assign all headers except parts_order, content_type and body
      assignable = headers.except(:parts_order, :content_type, :body, :template_name, :template_path)
      assignable.each { |k, v| m[k] = v }

      # Render the templates and blocks
      responses, explicit_order = collect_responses_and_parts_order(headers, &block)
      create_parts_from_responses(m, responses)

      # Setup content type, reapply charset and handle parts order
      m.content_type = set_content_type(m, content_type, headers[:content_type])
      m.charset      = charset

      if m.multipart?
        parts_order ||= explicit_order || headers[:parts_order]
        m.body.set_sort_order(parts_order)
        m.body.sort_parts!
      end

      m
    end

  protected

    def set_content_type(m, user_content_type, class_default)
      params = m.content_type_parameters || {}
      case
      when user_content_type.present?
        user_content_type
      when m.has_attachments?
        if m.attachments.detect { |a| a.inline? }
          ["multipart", "related", params]
        else
          ["multipart", "mixed", params]
        end
      when m.multipart?
        ["multipart", "alternative", params]
      else
        m.content_type || class_default
      end
    end

    def default_i18n_subject #:nodoc:
      mailer_scope = self.class.mailer_name.gsub('/', '.')
      I18n.t(:subject, :scope => [mailer_scope, action_name], :default => action_name.humanize)
    end

    def collect_responses_and_parts_order(headers) #:nodoc:
      responses, parts_order = [], nil

      if block_given?
        collector = ActionMailer::Collector.new(lookup_context) { render(action_name) }
        yield(collector)
        parts_order = collector.responses.map { |r| r[:content_type] }
        responses  = collector.responses
      elsif headers[:body]
        responses << {
          :body => headers.delete(:body),
          :content_type => self.class.default[:content_type] || "text/plain"
        }
      else
        templates_path = headers.delete(:template_path) || self.class.mailer_name
        templates_name = headers.delete(:template_name) || action_name

        each_template(templates_path, templates_name) do |template|
          self.formats = template.formats

          responses << {
            :body => render(:template => template),
            :content_type => template.mime_type.to_s
          }
        end
      end

      [responses, parts_order]
    end

    def each_template(paths, name, &block) #:nodoc:
      Array.wrap(paths).each do |path|
        templates = lookup_context.find_all(name, path)
        templates = templates.uniq_by { |t| t.formats }

        unless templates.empty?
          templates.each(&block)
          return
        end
      end
    end

    def create_parts_from_responses(m, responses) #:nodoc:
      if responses.size == 1 && !m.has_attachments?
        responses[0].each { |k,v| m[k] = v }
      elsif responses.size > 1 && m.has_attachments?
        container = Mail::Part.new
        container.content_type = "multipart/alternative"
        responses.each { |r| insert_part(container, r, m.charset) }
        m.add_part(container)
      else
        responses.each { |r| insert_part(m, r, m.charset) }
      end
    end

    def insert_part(container, response, charset) #:nodoc:
      response[:charset] ||= charset
      part = Mail::Part.new(response)
      container.add_part(part)
    end

    module DeprecatedUrlOptions
      def default_url_options
        deprecated_url_options
      end

      def default_url_options=(val)
        deprecated_url_options
      end

      def deprecated_url_options
        raise "You can no longer call ActionMailer::Base.default_url_options " \
              "directly. You need to set config.action_mailer.default_url_options. " \
              "If you are using ActionMailer standalone, you need to include the " \
              "routing url_helpers directly."
      end
    end

    # This module will complain if the user tries to set default_url_options
    # directly instead of through the config object. In Action Mailer's Railtie,
    # we include the router's url_helpers, which will override this module.
    extend DeprecatedUrlOptions

    ActiveSupport.run_load_hooks(:action_mailer, self)
  end
end

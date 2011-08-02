#
# Copyright (c) 2008 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

module Aws

    #
    # Aws::Sqs -- RightScale's Amazon SQS interface, API version
    # 2008-01-01 and later.
    # The Aws::Sqs class provides a complete interface to the second generation of Amazon's Simple
    # Queue Service.
    # For explanations of the semantics
    # of each call, please refer to Amazon's documentation at
    # http://developer.amazonwebservices.com/connect/kbcategory.jspa?categoryID=31
    #
    #
    # Aws::Sqs is built atop Aws::SqsInterface, a lower-level
    # procedural API that may be appropriate for certain programs.
    #
    # Error handling: all operations raise an Aws::AwsError in case
    # of problems. Note that transient errors are automatically retried.
    #
    #  sqs    = Aws::Sqs.new(aws_access_key_id, aws_secret_access_key)
    #  queue1 = sqs.queue('my_awesome_queue')
    #   ...
    #  queue2 = Aws::Sqs::Queue.create(sqs, 'my_cool_queue', true)
    #  puts queue2.size
    #   ...
    #  message1 = queue2.receive
    #  message1.visibility = 0
    #  puts message1
    #   ...
    #  queue2.clear(true)
    #  queue2.send_message('Ola-la!')
    #  message2 = queue2.pop
    #   ...
    #
    # NB: Second-generation SQS has eliminated the entire access grant mechanism present in Gen 1.
    #
    # Params is a hash:
    #
    #    {:server       => 'queue.amazonaws.com' # Amazon service host: 'queue.amazonaws.com' (default)
    #     :port         => 443                   # Amazon service port: 80 or 443 (default)
    #     :multi_thread => true|false            # Multi-threaded (connection per each thread): true or false (default)
    #     :signature_version => '0'              # The signature version : '0' or '1'(default)
    #     :logger       => Logger Object}        # Logger instance: logs to STDOUT if omitted }
  class Sqs
    attr_reader :interface

    def initialize(aws_access_key_id=nil, aws_secret_access_key=nil, params={})
      @interface = SqsInterface.new(aws_access_key_id, aws_secret_access_key, params)
    end

      # Retrieves a list of queues.
      # Returns an +array+ of +Queue+ instances.
      #
      #  Aws::Sqs.queues #=> array of queues
      #
    def queues(prefix=nil)
      @interface.list_queues(prefix).map do |url|
        Queue.new(self, url)
      end
    end

      # Returns Queue instance by queue name.
      # If the queue does not exist at Amazon SQS and +create+ is true, the method creates it.
      #
      #  Aws::Sqs.queue('my_awesome_queue') #=> #<Aws::Sqs::Queue:0xb7b626e4 ... >
      #
    def queue(queue_name, create=true, visibility=nil)
#      url = @interface.queue_url_by_name(queue_name)
#      url = (create ? @interface.create_queue(queue_name, visibility) : nil) unless url
      url = @interface.create_queue(queue_name, visibility) # this returns the url even if it exists
      url ? Queue.new(self, url) : nil
    end


    class Queue
      attr_reader :name, :url, :sqs

        # Returns Queue instance by queue name.
        # If the queue does not exist at Amazon SQS and +create+ is true, the method creates it.
        #
        #  Aws::Sqs::Queue.create(sqs, 'my_awesome_queue') #=> #<Aws::Sqs::Queue:0xb7b626e4 ... >
        #
      def self.create(sqs, url_or_name, create=true, visibility=nil)
        sqs.queue(url_or_name, create, visibility)
      end

        # Creates new Queue instance.
        # Does not create a queue at Amazon.
        #
        #  queue = Aws::Sqs::Queue.new(sqs, 'my_awesome_queue')
        #
      def initialize(sqs, url_or_name)
        @sqs  = sqs
        @url  = @sqs.interface.queue_url_by_name(url_or_name)
        @name = @sqs.interface.queue_name_by_url(@url)
      end

        # Retrieves queue size.
        #
        #  queue.size #=> 1
        #
      def size
        @sqs.interface.get_queue_length(@url)
      end

        # Clears queue, deleting only the visible messages.  Any message within its visibility
        # timeout will not be deleted, and will re-appear in the queue in the
        # future when the timeout expires.
        #
        # To delete all messages in a queue and eliminate the chance of any
        # messages re-appearing in the future, it's best to delete the queue and
        # re-create it as a new queue.  Note that doing this will take at least 60
        # s since SQS does not allow re-creation of a queue within this interval.
        #
        #  queue.clear() #=> true
        #
      def clear()
          @sqs.interface.clear_queue(@url)
      end

        # Deletes queue.  Any messages in the queue will be permanently lost.
        # Returns +true+.
        #
        # NB: Use with caution; severe data loss is possible!
        #
        # queue.delete(true) #=> true
        #
      def delete(force=false)
        @sqs.interface.delete_queue(@url)
      end

        # Sends new message to queue.
        # Returns new Message instance that has been sent to queue.
      def send_message(message)
        message = message.to_s
        res = @sqs.interface.send_message(@url, message)
        msg = Message.new(self, res['MessageId'], nil, message)
        msg.send_checksum = res['MD5OfMessageBody']
        msg.sent_at = Time.now
        msg
      end
      alias_method :push, :send_message

        # Retrieves several messages from queue.
        # Returns an array of Message instances.
        #
        #  queue.receive_messages(2,10) #=> array of messages
        #
      def receive_messages(number_of_messages=1, visibility=nil)
        list = @sqs.interface.receive_message(@url, number_of_messages, visibility)
        list.map! do |entry|
          msg = Message.new(self, entry['MessageId'], entry['ReceiptHandle'],
                            entry['Body'], visibility)
          msg.received_at = Time.now
          msg.receive_checksum = entry['MD5OfBody']
          msg
        end
      end

        # Retrieves first accessible message from queue.
        # Returns Message instance or +nil+ it the queue is empty.
        #
        #  queue.receive #=> #<Aws::Sqs::Message:0xb7bf0884 ... >
        #
      def receive(visibility=nil)
        list = receive_messages(1, visibility)
        list.empty? ? nil : list[0]
      end

        # Pops (and deletes) first accessible message from queue.
        # Returns Message instance or +nil+ if the queue is empty.
        #
        #  queue.pop #=> #<Aws::Sqs::Message:0xb7bf0884 ... >
        #
      def pop
        list = @sqs.interface.pop_messages(@url, 1)
        return nil if list.empty?
        entry = list[0]
        msg = Message.new(self, entry['MessageId'], entry['ReceiptHandle'],
                            entry['Body'], visibility)
        msg.received_at = Time.now
        msg.receive_checksum = entry['MD5OfBody']
        msg
      end

        # Retrieves +VisibilityTimeout+ value for the queue.
        # Returns new timeout value.
        #
        #  queue.visibility #=> 30
        #
      def visibility
        @sqs.interface.get_queue_attributes(@url, 'VisibilityTimeout')['VisibilityTimeout']
      end

        # Sets new +VisibilityTimeout+ for the queue.
        # Returns new timeout value.
        #
        #  queue.visibility #=> 30
        #  queue.visibility = 33
        #  queue.visibility #=> 33
        #
      def visibility=(visibility_timeout)
        @sqs.interface.set_queue_attributes(@url, 'VisibilityTimeout', visibility_timeout)
        visibility_timeout
      end

        # Sets new queue attribute value.
        # Not all attributes may be changed: +ApproximateNumberOfMessages+ (for example) is a read only attribute.
        # Returns a value to be assigned to attribute.
        # Currently, 'VisibilityTimeout' is the only settable queue attribute.
        # Attempting to set non-existent attributes generates an indignant
        # exception.
        #
        # queue.set_attribute('VisibilityTimeout', '100')  #=> '100'
        # queue.get_attribute('VisibilityTimeout')         #=> '100'
        #
      def set_attribute(attribute, value)
        @sqs.interface.set_queue_attributes(@url, attribute, value)
        value
      end

        # Retrieves queue attributes.
        # At this moment Amazon supports +VisibilityTimeout+ and +ApproximateNumberOfMessages+ only.
        # If the name of attribute is set, returns its value. Otherwise, returns a hash of attributes.
        #
        # queue.get_attribute('VisibilityTimeout')  #=> {"VisibilityTimeout"=>"45"}
        #
      def get_attribute(attribute='All')
        attributes = @sqs.interface.get_queue_attributes(@url, attribute)
        attribute=='All' ? attributes : attributes[attribute]
      end
    end

    class Message
      attr_reader   :queue, :id, :body, :visibility, :receipt_handle
      attr_accessor :sent_at, :received_at, :send_checksum, :receive_checksum

      def initialize(queue, id=nil, rh = nil, body=nil, visibility=nil)
        @queue       = queue
        @id          = id
        @receipt_handle = rh
        @body        = body
        @visibility  = visibility
        @sent_at     = nil
        @received_at = nil
        @send_checksum = nil
        @receive_checksum = nil
      end

        # Returns +Message+ instance body.
      def to_s
        @body
      end

        # Removes message from queue.
        # Returns +true+.
      def delete
        @queue.sqs.interface.delete_message(@queue.url, @receipt_handle) if @receipt_handle
      end

    end


  end
end

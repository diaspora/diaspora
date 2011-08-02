#!/usr/local/bin/ruby -w

# menu.rb
#
#  Created by Gregory Thomas Brown on 2005-05-10.
#  Copyright 2005. All rights reserved.
#
#  This is Free Software.  See LICENSE and COPYING for details.

require "highline/question"

class HighLine
  # 
  # Menu objects encapsulate all the details of a call to HighLine.choose().
  # Using the accessors and Menu.choice() and Menu.choices(), the block passed
  # to HighLine.choose() can detail all aspects of menu display and control.
  # 
  class Menu < Question
    #
    # Create an instance of HighLine::Menu.  All customization is done
    # through the passed block, which should call accessors and choice() and
    # choices() as needed to define the Menu.  Note that Menus are also
    # Questions, so all that functionality is available to the block as
    # well.
    # 
    def initialize(  )
      #
      # Initialize Question objects with ignored values, we'll
      # adjust ours as needed.
      # 
      super("Ignored", [ ], &nil)    # avoiding passing the block along
      
      @items           = [ ]
      @hidden_items    = [ ]
      @help            = Hash.new("There's no help for that topic.")

      @index           = :number
      @index_suffix    = ". "
      @select_by       = :index_or_name
      @flow            = :rows
      @list_option     = nil
      @header          = nil
      @prompt          = "?  "
      @layout          = :list
      @shell           = false
      @nil_on_handled  = false
      
      # Override Questions responses, we'll set our own.
      @responses       = { }
      # Context for action code.
      @highline        = nil
      
      yield self if block_given?

      init_help if @shell and not @help.empty?
    end

    #
    # An _index_ to append to each menu item in display.  See
    # Menu.index=() for details.
    # 
    attr_reader   :index
    #
    # The String placed between an _index_ and a menu item.  Defaults to
    # ". ".  Switches to " ", when _index_ is set to a String (like "-").
    #
    attr_accessor :index_suffix
    # 
    # The _select_by_ attribute controls how the user is allowed to pick a 
    # menu item.  The available choices are:
    # 
    # <tt>:index</tt>::          The user is allowed to type the numerical
    #                            or alphetical index for their selection.
    # <tt>:index_or_name</tt>::  Allows both methods from the
    #                            <tt>:index</tt> option and the
    #                            <tt>:name</tt> option.
    # <tt>:name</tt>::           Menu items are selected by typing a portion
    #                            of the item name that will be
    #                            auto-completed.
    # 
    attr_accessor :select_by
    # 
    # This attribute is passed directly on as the mode to HighLine.list() by
    # all the preset layouts.  See that method for appropriate settings.
    # 
    attr_accessor :flow
    #
    # This setting is passed on as the third parameter to HighLine.list()
    # by all the preset layouts.  See that method for details of its
    # effects.  Defaults to +nil+.
    # 
    attr_accessor :list_option
    #
    # Used by all the preset layouts to display title and/or introductory
    # information, when set.  Defaults to +nil+.
    # 
    attr_accessor :header
    #
    # Used by all the preset layouts to ask the actual question to fetch a
    # menu selection from the user.  Defaults to "?  ".
    # 
    attr_accessor :prompt
    #
    # An ERb _layout_ to use when displaying this Menu object.  See
    # Menu.layout=() for details.
    # 
    attr_reader   :layout
    #
    # When set to +true+, responses are allowed to be an entire line of
    # input, including details beyond the command itself.  Only the first
    # "word" of input will be matched against the menu choices, but both the
    # command selected and the rest of the line will be passed to provided
    # action blocks.  Defaults to +false+.
    # 
    attr_accessor :shell
    #
    # When +true+, any selected item handled by provided action code, will
    # return +nil+, instead of the results to the action code.  This may
    # prove handy when dealing with mixed menus where only the names of
    # items without any code (and +nil+, of course) will be returned.
    # Defaults to +false+.
    # 
    attr_accessor :nil_on_handled
    
    #
    # Adds _name_ to the list of available menu items.  Menu items will be
    # displayed in the order they are added.
    # 
    # An optional _action_ can be associated with this name and if provided,
    # it will be called if the item is selected.  The result of the method
    # will be returned, unless _nil_on_handled_ is set (when you would get
    # +nil+ instead).  In _shell_ mode, a provided block will be passed the
    # command chosen and any details that followed the command.  Otherwise,
    # just the command is passed.  The <tt>@highline</tt> variable is set to
    # the current HighLine context before the action code is called and can
    # thus be used for adding output and the like.
    # 
    def choice( name, help = nil, &action )
      @items << [name, action]
      
      @help[name.to_s.downcase] = help unless help.nil?
      update_responses  # rebuild responses based on our settings
    end
    
    #
    # A shortcut for multiple calls to the sister method choice().  <b>Be
    # warned:</b>  An _action_ set here will apply to *all* provided
    # _names_.  This is considered to be a feature, so you can easily
    # hand-off interface processing to a different chunk of code.
    # 
    def choices( *names, &action )
      names.each { |n| choice(n, &action) }
    end

    # Identical to choice(), but the item will not be listed for the user.
    def hidden( name, help = nil, &action )
      @hidden_items << [name, action]
      
      @help[name.to_s.downcase] = help unless help.nil?
    end
    
    # 
    # Sets the indexing style for this Menu object.  Indexes are appended to
    # menu items, when displayed in list form.  The available settings are:
    # 
    # <tt>:number</tt>::   Menu items will be indexed numerically, starting
    #                      with 1.  This is the default method of indexing.
    # <tt>:letter</tt>::   Items will be indexed alphabetically, starting
    #                      with a.
    # <tt>:none</tt>::     No index will be appended to menu items.
    # <i>any String</i>::  Will be used as the literal _index_.
    # 
    # Setting the _index_ to <tt>:none</tt> a literal String, also adjusts
    # _index_suffix_ to a single space and _select_by_ to <tt>:none</tt>. 
    # Because of this, you should make a habit of setting the _index_ first.
    # 
    def index=( style )
      @index = style
      
      # Default settings.
      if @index == :none or @index.is_a?(String)
        @index_suffix = " "
        @select_by    = :name
      end
    end
    
    # 
    # Initializes the help system by adding a <tt>:help</tt> choice, some
    # action code, and the default help listing.
    # 
    def init_help(  )
      return if @items.include?(:help)
      
      topics    = @help.keys.sort
      help_help = @help.include?("help") ? @help["help"] :
                  "This command will display helpful messages about " +
                  "functionality, like this one.  To see the help for " +
                  "a specific topic enter:\n\thelp [TOPIC]\nTry asking " +
                  "for help on any of the following:\n\n" +
                  "<%= list(#{topics.inspect}, :columns_across) %>"
      choice(:help, help_help) do |command, topic|
        topic.strip!
        topic.downcase!
        if topic.empty?
          @highline.say(@help["help"])
        else
          @highline.say("= #{topic}\n\n#{@help[topic]}")
        end
      end
    end
    
    #
    # Used to set help for arbitrary topics.  Use the topic <tt>"help"</tt>
    # to override the default message.
    # 
    def help( topic, help )
      @help[topic] = help
    end
    
    # 
    # Setting a _layout_ with this method also adjusts some other attributes
    # of the Menu object, to ideal defaults for the chosen _layout_.  To
    # account for that, you probably want to set a _layout_ first in your
    # configuration block, if needed.
    # 
    # Accepted settings for _layout_ are:
    #
    # <tt>:list</tt>::         The default _layout_.  The _header_ if set
    #                          will appear at the top on its own line with
    #                          a trailing colon.  Then the list of menu
    #                          items will follow.  Finally, the _prompt_
    #                          will be used as the ask()-like question.
    # <tt>:one_line</tt>::     A shorter _layout_ that fits on one line.  
    #                          The _header_ comes first followed by a
    #                          colon and spaces, then the _prompt_ with menu
    #                          items between trailing parenthesis.
    # <tt>:menu_only</tt>::    Just the menu items, followed up by a likely
    #                          short _prompt_.
    # <i>any ERb String</i>::  Will be taken as the literal _layout_.  This
    #                          String can access <tt>@header</tt>, 
    #                          <tt>@menu</tt> and <tt>@prompt</tt>, but is
    #                          otherwise evaluated in the typical HighLine
    #                          context, to provide access to utilities like
    #                          HighLine.list() primarily.
    # 
    # If set to either <tt>:one_line</tt>, or <tt>:menu_only</tt>, _index_
    # will default to <tt>:none</tt> and _flow_ will default to
    # <tt>:inline</tt>.
    # 
    def layout=( new_layout )
      @layout = new_layout
      
      # Default settings.
      case @layout
      when :one_line, :menu_only
        self.index = :none
        @flow  = :inline
      end
    end

    #
    # This method returns all possible options for auto-completion, based
    # on the settings of _index_ and _select_by_.
    # 
    def options(  )
      # add in any hidden menu commands
      @items.concat(@hidden_items)
      
      by_index = if @index == :letter
        l_index = "`"
        @items.map { "#{l_index.succ!}" }
      else
        (1 .. @items.size).collect { |s| String(s) }
      end
      by_name = @items.collect { |c| c.first }

      case @select_by
      when :index then
        by_index
      when :name
        by_name
      else
        by_index + by_name
      end
    ensure
      # make sure the hidden items are removed, before we return
      @items.slice!(@items.size - @hidden_items.size, @hidden_items.size)
    end

    #
    # This method processes the auto-completed user selection, based on the
    # rules for this Menu object.  If an action was provided for the 
    # selection, it will be executed as described in Menu.choice().
    # 
    def select( highline_context, selection, details = nil )
      # add in any hidden menu commands
      @items.concat(@hidden_items)
      
      # Find the selected action.
      name, action = if selection =~ /^\d+$/
        @items[selection.to_i - 1]
      else
        l_index = "`"
        index = @items.map { "#{l_index.succ!}" }.index(selection)
        @items.find { |c| c.first == selection } or @items[index]
      end
      
      # Run or return it.
      if not action.nil?
        @highline = highline_context
        if @shell
          result = action.call(name, details)
        else
          result = action.call(name)
        end
        @nil_on_handled ? nil : result
      elsif action.nil?
        name
      else
        nil
      end
    ensure
      # make sure the hidden items are removed, before we return
      @items.slice!(@items.size - @hidden_items.size, @hidden_items.size)
    end
    
    #
    # Allows Menu objects to pass as Arrays, for use with HighLine.list().
    # This method returns all menu items to be displayed, complete with
    # indexes.
    # 
    def to_ary(  )
      case @index
      when :number
        @items.map { |c| "#{@items.index(c) + 1}#{@index_suffix}#{c.first}" }
      when :letter
        l_index = "`"
        @items.map { |c| "#{l_index.succ!}#{@index_suffix}#{c.first}" }
      when :none
        @items.map { |c| "#{c.first}" }
      else
        @items.map { |c| "#{index}#{@index_suffix}#{c.first}" }
      end
    end
    
    #
    # Allows Menu to behave as a String, just like Question.  Returns the
    # _layout_ to be rendered, which is used by HighLine.say().
    # 
    def to_str(  )
      case @layout
      when :list
        '<%= if @header.nil? then '' else "#{@header}:\n" end %>' +
        "<%= list( @menu, #{@flow.inspect},
                          #{@list_option.inspect} ) %>" +
        "<%= @prompt %>"
      when :one_line
        '<%= if @header.nil? then '' else "#{@header}:  " end %>' +
        "<%= @prompt %>" +
        "(<%= list( @menu, #{@flow.inspect},
                           #{@list_option.inspect} ) %>)" +
        "<%= @prompt[/\s*$/] %>"
      when :menu_only
        "<%= list( @menu, #{@flow.inspect},
                          #{@list_option.inspect} ) %><%= @prompt %>"
      else
        @layout
      end
    end      

    #
    # This method will update the intelligent responses to account for
    # Menu specific differences.  This overrides the work done by 
    # Question.build_responses().
    # 
    def update_responses(  )
      append_default unless default.nil?
      @responses = @responses.merge(
                     :ambiguous_completion =>
                       "Ambiguous choice.  " +
                       "Please choose one of #{options.inspect}.",
                     :ask_on_error         =>
                       "?  ",
                     :invalid_type         =>
                       "You must enter a valid #{options}.",
                     :no_completion        =>
                       "You must choose one of " +
                       "#{options.inspect}.",
                     :not_in_range         =>
                       "Your answer isn't within the expected range " +
                       "(#{expected_range}).",
                     :not_valid            =>
                       "Your answer isn't valid (must match " +
                       "#{@validate.inspect})."
                   )
    end
  end
end

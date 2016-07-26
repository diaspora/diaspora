// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Hovercard = app.views.Base.extend({
  triggerChar: "@",
  invisibleChar: "\u200B", // zero width space
  mentionRegex: /@([^@\s]+)$/,

  templateName: 'hovercard',
  id: 'hovercard_container',

  templates: {
    mentionItemSyntax: _.template("@{<%= name %> ; <%= handle %>}"),
    mentionItemHighlight: _.template("<strong><span><%= name %></span></strong>")
  },

  events: {
    'mouseleave': '_mouseleaveHandler',
    "keydown #status_message_fake_text": "onInputBoxKeyDown",
    "input #status_message_fake_text": "onInputBoxInput",
    "click #status_message_fake_text": "onInputBoxClick",
    "blur #status_message_fake_text": "onInputBoxBlur",
    "click #mention_button": "showMentionModal",
    "click #message_button": "showMessageModal",
    "keydown textarea#conversation_text" : "keyDown",
    "conversation:loaded" : "setupConversation",
    "click .conversation_button": "showMessageModal",
  },

  initialize: function() {
    this.render();
    console.log($('#mention_button'));
    $(document)
      .on('mouseenter', '.hovercardable', _.bind(this._mouseenterHandler, this))
      .on('mouseleave', '.hovercardable', _.bind(this._mouseleaveHandler, this))
      .on('click', '#mention_button', function() {
        $('#hovercard_container').fadeOut('fast');
      })
      .on('click', '#message_button', function() {
        $('#hovercard_container').fadeOut('fast');
      });

    this.showMe = false;
    this.parent = null;  // current 'hovercardable' element that caused HC to appear

    // cache some element references
    this.avatar = this.$('.avatar');
    this.avatarLink = this.$("a.person_avatar");
    this.dropdown_container = this.$('#hovercard_dropdown_container');
    this.hashtags = this.$('.hashtags');
    this.person_link = this.$('a.person');
    this.person_handle = this.$('div.handle');
    this.person_mention_button = this.$('#mention_button');
    this.person_message_button = this.$('#message_button');
    // this.person_message_link = this.$("a.message");
    this.active = true;

    if($("#conversation_new:visible").length > 0) {
      new app.views.ConversationsForm({
        el: $("#conversation_new"),
        contacts: gon.contacts
      });
    }
    this.setupConversation();
  },



  setupConversation: function() {
    app.helpers.timeago($(this.el));
    $(".control-icons a").tooltip({placement: "bottom"});

    var conv = $(".conversation-wrapper .stream_element.selected"),
        cBadge = $("#conversations-link .badge");

    if(conv.hasClass("unread") ){
      var unreadCount = parseInt(conv.find(".unread-message-count").text(), 10);

      if(cBadge.text() !== "") {
        cBadge.text().replace(/\d+/, function(num){
          num = parseInt(num, 10) - unreadCount;
          if(num > 0) {
            cBadge.text(num);
          } else {
            cBadge.text(0).addClass("hidden");
          }
        });
      }
      conv.removeClass("unread");
      conv.find(".unread-message-count").remove();

      var pos = $("#first_unread").offset().top - 50;
      $("html").animate({scrollTop:pos});
    } else {
      $("html").animate({scrollTop:0});
    }
  },

  postRenderTemplate: function() {
    this.$el.appendTo($('body'));
  },

  deactivate: function() {
    this.active = false;
  },

  href: function() {
    return this.parent.attr('href');
  },

  _mouseenterHandler: function(event) {
    if( this.active === false ||
        $.contains(this.el, event.target) ) { return false; }

    var el = $(event.target);
    if( !el.is('a') ) {
      el = el.parents('a');
    }

    if( el.attr('href').indexOf('/people') === -1 ) {
      // can't fetch data from that URL, aborting
      return false;
    }

    this.showMe = true;
    this.showHovercardOn(el);
    return false;
  },

  _mouseleaveHandler: function(event) {
    this.showMe = false;
    if( this.active === false ||
      $.contains(this.el, event.relatedTarget) ) { return false; }

    if( this.mouseIsOverElement(this.parent, event) ||
      this.mouseIsOverElement(this.$el, event) ) { return false; }

    if( this.$el.is(':visible') ) {
      this.$el.fadeOut('fast');
    } else {
      this.$el.hide();
    }

    this.dropdown_container.unbind().empty();
    return false;
  },

  showHovercardOn: _.debounce(function(element) {
    var el = $(element);
    var hc = this.$el;

    if( !this.showMe ) {
      // mouse has left element
      return;
    }

    hc.hide();
    this.parent = el;
    this._positionHovercard();
    this._populateHovercard();
  }, 700),

  _populateHovercard: function() {
    var href = this.href();
    href += "/hovercard.json";
    //console.log('calling ' + href);

    var self = this;
    $.ajax(href, {preventGlobalErrorHandling: true}).done(function(person){
      if( !person || person.length === 0 ) {
        throw new Error("received data is not a person object");
      }

      self._populateHovercardWith(person);
      if( !self.showMe ) {
        // mouse has left element
        return;
      }
      self.$el.fadeIn('fast');
    });
  },

  _populateHovercardWith: function(person) {
    var self = this;
    
    this.avatar.attr('src', person.avatar);
    this.avatarLink.attr("href", person.url);
    this.person_link.attr('href', person.url);
    this.person_link.text(person.name);
    this.person_handle.text(person.handle);
    this.person_mention_button.attr('data-status-message-path', person.status_url);
    this.person_mention_button.attr('data-title', person.title);
    this.person_message_button.attr('data-conversation-path', person.message_url);
    //message t
    this.person_mention_button.attr('data-title-message', person.title_message);
    // window.ppp=person;

    // set hashtags
    this.hashtags.empty();
    this.hashtags.html( $(_.map(person.tags, function(tag){
      return $('<a/>',{href: "/tags/"+tag.substring(1)}).text(tag)[0] ;
    })) );

    if(!app.currentUser.authenticated()){ return; }
    // set aspect dropdown
    // TODO render me client side!!!
    var href = this.href();
    href += "/aspect_membership_button";
    $.ajax(href, {preventGlobalErrorHandling: true}).done(function(response){
      self.dropdown_container.html(response);
    });
    new app.views.AspectMembership({el: self.dropdown_container});
  },

  showMentionModal: function(e) {
    var statusMessagePath = e.target.getAttribute('data-status-message-path');
    var title = e.target.getAttribute('data-title');
    app.helpers.showModal("#mentionModal", statusMessagePath, title);
  },

  showMessageModal: function(e){
    var conversationPath = e.target.getAttribute('data-conversation-path');
    var title_message = e.target.getAttribute('data-title-message');
    app.helpers.showModal("#conversationModal", conversationPath, title_message);
  },

  keyDown : function(evt) {
    if(evt.which === Keycodes.ENTER && evt.ctrlKey) {
      $(evt.target).parents("form").submit();
    }
  },

  _positionHovercard: function() {
    var p_pos = this.parent.offset();
    var p_height = this.parent.height();

    this.$el.css({
      top: p_pos.top + p_height - 25,
      left: p_pos.left
    });
  },

  mouseIsOverElement: function(element, event) {
    if(!element) { return false; }
    var elPos = element.offset();
    return event.pageX >= elPos.left &&
      event.pageX <= elPos.left + element.width() &&
      event.pageY >= elPos.top &&
      event.pageY <= elPos.top + element.height();
  }
});
// @license-end

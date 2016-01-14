// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Hovercard = app.views.Base.extend({
  templateName: 'hovercard',
  id: 'hovercard_container',

  events: {
    'mouseleave': '_mouseleaveHandler'
  },

  initialize: function() {
    this.render();

    $(document)
      .on('mouseenter', '.hovercardable', _.bind(this._mouseenterHandler, this))
      .on('mouseleave', '.hovercardable', _.bind(this._mouseleaveHandler, this));

    this.showMe = false;
    this.parent = null;  // current 'hovercardable' element that caused HC to appear

    // cache some element references
    this.avatar = this.$('.avatar');
    this.avatarLink = this.$("a.person_avatar");
    this.dropdown_container = this.$('#hovercard_dropdown_container');
    this.hashtags = this.$('.hashtags');
    this.person_link = this.$('a.person');
    this.person_handle = this.$('div.handle');
    this.active = true;
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
  },
});
// @license-end

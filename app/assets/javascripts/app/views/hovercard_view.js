
app.views.Hovercard = Backbone.View.extend({
  el: '#hovercard_container',

  initialize: function() {
    $('.hovercardable')
      .live('mouseenter', _.bind(this._mouseenterHandler, this))
      .live('mouseleave', _.bind(this._mouseleaveHandler, this));

    this.show_me = false;

    this.avatar = this.$('.avatar');
    this.dropdown = this.$('.dropdown_list');
    this.dropdown_container = this.$('#hovercard_dropdown_container');
    this.hashtags = this.$('.hashtags');
    this.person_link = this.$('a.person');
    this.person_handle = this.$('p.handle');
    this.active = true;
  },

  deactivate: function() {
    this.active = false;
  },

  href: function() {
    return this.$el.parent().attr('href');
  },

  _mouseenterHandler: function(event) {
    if(this.active == false) { return false }
    var el = $(event.target);
    if( !el.is('a') ) {
      el = el.parents('a');
    }

    if( el.attr('href').indexOf('/people') == -1 ) {
      // can't fetch data from that URL, aborting
      return false;
    }

    this.show_me = true;
    this.showHovercardOn(el);
    return false;
  },

  _mouseleaveHandler: function(event) {
    if(this.active == false) { return false }
    this.show_me = false;
    if( this.$el.is(':visible') ) {
      this.$el.fadeOut('fast');
    } else {
      this.$el.hide();
    }

    this.dropdown_container.empty();
    return false;
  },

  showHovercardOn: _.debounce(function(element) {
    var el = $(element);
    var hc = this.$el;

    if( !this.show_me ) {
      // mouse has left element
      return;
    }

    hc.hide();
    hc.prependTo(el);
    this._positionHovercard();
    this._populateHovercard();
  }, 500, true),

  _populateHovercard: function() {
    var href = this.href();
    href += "/hovercard.json";

    var self = this;
    $.get(href, function(person){
      if( !person || person.length == 0 ) {
        throw new Error("received data is not a person object");
      }

      self._populateHovercardWith(person);
      self.$el.fadeIn('fast');
    });
  },

  _populateHovercardWith: function(person) {
    var self = this;

    this.avatar.attr('src', person.avatar);
    this.person_link.attr('href', person.url);
    this.person_link.text(person.name);
    this.person_handle.text(person.handle);
    this.dropdown.attr('data-person-id', person.id);

    // set hashtags
    this.hashtags.empty();
    this.hashtags.html( $(_.map(person.tags, function(tag){
      return $('<a/>',{href: "/tags/"+tag.substring(1)}).text(tag)[0] ;
    })) );

    // set aspect dropdown
    var href = this.href();
    href += "/aspect_membership_button"
    $.get(href, function(response) {
      self.dropdown_container.html(response);
    });
  },

  _positionHovercard: function() {
    var p = this.$el.parent();
    var p_pos = p.position();
    var p_height = p.height();

    this.$el.css({
      top: p_pos.top + p_height - 25,
      left: p_pos.left
    });
  }
});

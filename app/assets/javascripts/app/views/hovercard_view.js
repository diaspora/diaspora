
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

    this.show_me = false;
    this.parent = null;  // current 'hovercarable' element that caused HC to appear

    // cache some element references
    this.avatar = this.$('.avatar');
    this.dropdown = this.$('.dropdown_list');
    this.dropdown_container = this.$('#hovercard_dropdown_container');
    this.hashtags = this.$('.hashtags');
    this.person_link = this.$('a.person');
    this.person_handle = this.$('div.handle');
    this.active = true;
  },

  postRenderTemplate: function() {
    this.$el.appendTo($('body'))
  },

  deactivate: function() {
    this.active = false;
  },

  href: function() {
    return this.parent.attr('href');
  },

  _mouseenterHandler: function(event) {
    if( this.active == false ||
        $.contains(this.el, event.target) ) { return false; }

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
    if( this.active == false ||
        $.contains(this.el, event.relatedTarget) ) { return false; }

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
    this.parent = el;
    this._positionHovercard();
    this._populateHovercard();
  }, 700),

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
    href += "/aspect_membership_button";
    if(gon.bootstrap == true){
      href += "?bootstrap=true";
    }
    $.get(href, function(response) {
      self.dropdown_container.html(response);
    });
    var aspect_membership = new app.views.AspectMembership({el: self.dropdown_container});
  },

  _positionHovercard: function() {
    var p_pos = this.parent.offset();
    var p_height = this.parent.height();

    this.$el.css({
      top: p_pos.top + p_height - 25,
      left: p_pos.left
    });
  }
});

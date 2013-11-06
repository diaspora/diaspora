//TODO RS: Would be nice to have #faq as the root elem or something
app.views.Help = app.views.Base.extend({
  templateName : "help",
  // className : "dark-header",

  events : {
    "click .faq-link" : "sectionClicked",
    "click .faq-link-getting-help" : "gettingHelp",
    "click .faq-link-sharing" : "sharing",
    "click .faq-link-posts-and-posting" : "postsAndPosting"
  },

  initialize : function(options) {
    // TODO RS: Set menu link text from js i18n
    // TODO RS: Highlight menu item on click
    return this;
  },

  afterRender: function() {
    this.renderStaticSection("getting_help", "faq_getting_help");
  },

  showItems: function(el) {
    this.clearItems();
    var section = el.data('section');
    var items = el.data('items').split(" ");

    items.forEach(function(item, i){
      var qa = {question: this.getText(section, item, true),
              answer: this.getText(section, item, false)};
      item = new app.views.FaqQuestionView(qa);
      $('#faq').append(item.render().el);
    }, this);

    this.setInitialVisibility();
  },

  getText: function(section, name, question){
    var q = question ? "_q" : "_a";
    return Diaspora.I18n.t( section + '.' + name + q);
  },

  setInitialVisibility: function() {
    $('#faq .question.collapsible :first').addClass('opened').removeClass('collapsed');
    $('#faq .question.collapsible .answer :first').show();
  },

  clearItems: function() {
    $('#faq').empty();
  },

  sectionClicked : function(e) {
    this.showItems($(e.target));

    e.preventDefault();
  },

  renderStaticSection: function(section, template) {
    data = Diaspora.I18n.locale[section];
    section = new app.views.StaticContentView(template, data);
    $('#faq').append(section.render().el);
  },

  gettingHelp: function(e) {
    this.clearItems();
    this.renderStaticSection("getting_help", "faq_getting_help");

    e.preventDefault();
  },

  sharing: function(e) {
    this.clearItems();
    this.renderStaticSection("sharing", "faq_sharing");

    e.preventDefault();
  },

  postsAndPosting: function(e) {
    this.clearItems();
    this.renderStaticSection("posts_and_posting", "faq_posts_and_posting");

    e.preventDefault();
  },
});
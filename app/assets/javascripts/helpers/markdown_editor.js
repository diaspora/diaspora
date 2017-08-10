Diaspora.MarkdownEditor = function(element, opts) {
  this.initialize(element, opts);
};

Diaspora.MarkdownEditor.prototype = {
  constructor: Diaspora.MarkdownEditor,

  initialize: function(element, opts) {
    this.options = {
      resize: "none",
      onHidePreview: $.noop,
      onPostPreview: $.noop,
      onChange: function(e) { autosize.update(e.$textarea); }
    };

    $.extend(this.options, opts);

    this.options.fullscreen = {enable: false, icons: {}};
    this.options.language = this.localize();
    this.options.hiddenButtons = ["cmdPreview"];
    this.options.onShow = this.onShow.bind(this);

    $(element).markdown(this.options);
  },

  /**
   * Attach the $.fn.markdown instance to the current MarkdownEditor instance
   * and initializes the preview and edit tabs after the editor is shown.
   * @param instance
   */
  onShow: function(instance) {
    this.instance = instance;

    if (_.isFunction(this.options.onPreview)) {
      instance.$editor.find(".md-header").remove(".write-preview-tabs").prepend(this.createTabsElement());
    }

    if (_.isFunction(this.options.onClose)) {
      instance.$editor.find(".md-header").remove(".md-cancel").append(this.createCloseElement());
    }

    // Monkey patch to change icons. Will have to PR upstream
    var icons = {
      cmdUrl: ["glyphicon-link", "entypo-link"],
      cmdImage: ["glyphicon-picture", "entypo-picture"],
      cmdList: ["glyphicon-list", "entypo-list"],
      cmdListO: ["glyphicon-th-list", "entypo-numbered-list"],
      cmdCode: ["glyphicon-asterisk", "entypo-code"],
      cmdQuote: ["glyphicon-comment", "entypo-comment"]
    };

    Object.keys(icons).forEach(function(key) {
      instance.$editor.find("[data-handler='bootstrap-markdown-" + key + "']").find(".glyphicon")
        .removeClass("glyphicon").removeClass(icons[key][0])
        .addClass(icons[key][1]);
    });
  },

  /**
   * Creates write and preview tabs inside the markdown editor header.
   * @returns {jQuery} The created tabs
   */
  createTabsElement: function() {
    var self = this;

    var tabElement = $("<ul class='nav nav-tabs btn-group write-preview-tabs'></ul>");

    var writeTab = $("<li class='active full-height' role='presentation'></li>");
    this.writeLink = $("<a class='full-height md-write-tab' href='#' data-target=' '></a>")
      .attr("title", Diaspora.I18n.t("publisher.markdown_editor.tooltips.write"));

    this.writeLink.append($("<i class='visible-sm visible-xs visible-md diaspora-custom-compose'></i>"));
    this.writeLink.append($("<span class='hidden-sm hidden-xs hidden-md tab-help-text'></span>")
      .text(Diaspora.I18n.t("publisher.markdown_editor.write")));

    this.writeLink.click(function(evt) {
      evt.preventDefault();
      self.hidePreview();
    });

    writeTab.append(this.writeLink);

    var previewTab = $("<li class='full-height' role='presentation'></li>");
    this.previewLink = $("<a class='full-height md-preview-tab' href='#' data-target=' '></a>")
      .attr("title", Diaspora.I18n.t("publisher.markdown_editor.tooltips.preview"));

    this.previewLink.append($("<i class='visible-sm visible-xs visible-md entypo-search'>"));
    this.previewLink.append($("<span class='hidden-sm hidden-xs hidden-md tab-help-text'></span>")
      .text(Diaspora.I18n.t("publisher.markdown_editor.preview")));

    this.previewLink.click(function(evt) {
      evt.preventDefault();
      self.showPreview();
    });

    previewTab.append(this.previewLink);

    return tabElement.append(writeTab).append(previewTab);
  },

  /**
   * Creates a cancel button that executes {options#onClose} on click.
   * @returns {jQuery} The created cancel button
   */
  createCloseElement: function() {
    var self = this;
    var button = $("<a class='md-cancel btn btn-sm btn-link hidden-xs pull-right'></a>")
      .attr("title", Diaspora.I18n.t("publisher.markdown_editor.tooltips.cancel"));

    button.click(function() {
      self.hidePreview();
      self.options.onClose();
    });

    return button.append($("<i class='entypo-cross'></i>"));
  },

  hidePreview: function() {
    if (this.writeLink) {
      this.writeLink.tab("show");
      this.instance.hidePreview();
      this.options.onHidePreview();
    }
  },

  showPreview: function() {
    if (this.previewLink) {
      this.previewLink.tab("show");
      this.instance.showPreview();
      this.options.onPostPreview();
    }
  },

  isPreviewMode: function() {
    return this.instance !== undefined && this.instance.$editor.find(".md-preview").length > 0;
  },

  userInputEmpty: function() {
    return this.instance === undefined || this.instance.getContent().length === 0;
  },

  localize: function() {
    var locale = Diaspora.I18n.language;

    $.fn.markdown.messages[locale] = {
      "Bold": Diaspora.I18n.t("publisher.markdown_editor.tooltips.bold"),
      "Italic": Diaspora.I18n.t("publisher.markdown_editor.tooltips.italic"),
      "Heading": Diaspora.I18n.t("publisher.markdown_editor.tooltips.heading"),
      "URL/Link": Diaspora.I18n.t("publisher.markdown_editor.tooltips.insert_link"),
      "Image": Diaspora.I18n.t("publisher.markdown_editor.tooltips.insert_image"),
      "Ordered List": Diaspora.I18n.t("publisher.markdown_editor.tooltips.insert_ordered_list"),
      "Unordered List": Diaspora.I18n.t("publisher.markdown_editor.tooltips.insert_unordered_list"),
      "Preview": Diaspora.I18n.t("publisher.markdown_editor.tooltips.preview"),
      "Quote": Diaspora.I18n.t("publisher.markdown_editor.tooltips.quote"),
      "Code": Diaspora.I18n.t("publisher.markdown_editor.tooltips.code"),
      "strong text": Diaspora.I18n.t("publisher.markdown_editor.texts.strong"),
      "emphasized text": Diaspora.I18n.t("publisher.markdown_editor.texts.italic"),
      "heading text": Diaspora.I18n.t("publisher.markdown_editor.texts.heading"),
      "enter link description here": Diaspora.I18n.t("publisher.markdown_editor.texts.insert_link_description_text"),
      "Insert Hyperlink": Diaspora.I18n.t("publisher.markdown_editor.texts.insert_link_help_text"),
      "enter image description here": Diaspora.I18n.t("publisher.markdown_editor.texts.insert_image_description_text"),
      "Insert Image Hyperlink": Diaspora.I18n.t("publisher.markdown_editor.texts.insert_image_help_text"),
      "enter image title here": Diaspora.I18n.t("publisher.markdown_editor.texts.insert_image_title"),
      "list text here": Diaspora.I18n.t("publisher.markdown_editor.texts.list"),
      "quote here": Diaspora.I18n.t("publisher.markdown_editor.texts.quote"),
      "code text here": Diaspora.I18n.t("publisher.markdown_editor.texts.code")
    };

    return locale;
  }
};

Diaspora.MarkdownEditor.simplePreview = function($mdInstance) {
  return "<div class='preview-content'>" + app.helpers.textFormatter($mdInstance.getContent()) + "</div>";
};

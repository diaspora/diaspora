Diaspora.MarkdownEditor = class {
  constructor(element, opts) {
    this.options = {
      resize: "none",
      onHidePreview: $.noop,
      onPostPreview: $.noop
    };

    $.extend(this.options, opts);

    this.options.fullscreen = {enable: false, icons: {}};
    this.options.language = this.localize();
    this.options.hiddenButtons = ["cmdPreview"];
    this.options.onShow = this.onShow.bind(this);

    $(element).markdown(this.options);
  }

  /**
   * Attach the $.fn.markdown instance to the current MarkdownEditor instance
   * and initializes the preview and edit tabs after the editor is shown.
   * @param instance
   */
  onShow(instance) {
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
  }

  /**
   * Creates write and preview tabs inside the markdown editor header.
   * @returns {jQuery} The created tabs
   */
  createTabsElement() {
    var tabHtml = `<ul class="nav nav-tabs btn-group write-preview-tabs">
      <li class="active full-height" role="presentation">
        <a class="full-height md-write-tab" href="#" 
           title="${Diaspora.I18n.t("publisher.markdown_editor.tooltips.write")}">
          <i class="visible-sm visible-xs visible-md diaspora-custom-compose"></i>  
          <span class="hidden-sm hidden-xs hidden-md tab-help-text">
            ${Diaspora.I18n.t("publisher.markdown_editor.write")}
          </span>
        </a>
      </li>
      <li class="full-height" role="presentation">
        <a class="full-height md-preview-tab" href="#"
           title="${Diaspora.I18n.t("publisher.markdown_editor.tooltips.preview")}">
          <i class="visible-sm visible-xs visible-md entypo-search"></i>
          <span class="hidden-sm hidden-xs hidden-md tab-help-text">
            ${(Diaspora.I18n.t("publisher.markdown_editor.preview"))}
          </span>
        </a>
      </li>
    </ul>`;

    var tabElement = $(tabHtml);

    this.writeLink = tabElement.find(".md-write-tab");
    this.writeLink.click((evt) => {
      evt.preventDefault();
      this.hidePreview();
    });

    this.previewLink = tabElement.find(".md-preview-tab");
    this.previewLink.click((evt) => {
      evt.preventDefault();
      this.showPreview();
    });

    return tabElement;
  }

  /**
   * Creates a cancel button that executes {options#onClose} on click.
   * @returns {jQuery} The created cancel button
   */
  createCloseElement() {
    var closeBtnHtml = `<a class="md-cancel btn btn-sm btn-link hidden-xs pull-right"
                           title="${Diaspora.I18n.t("publisher.markdown_editor.tooltips.cancel")}">
      <i class="entypo-cross"></i>
    </a>`;

    return $(closeBtnHtml).click(() => {
      this.hidePreview();
      this.options.onClose();
    });
  }

  hidePreview() {
    if (this.writeLink) {
      this.writeLink.tab("show");
      this.instance.hidePreview();
      this.options.onHidePreview();
    }
  }

  showPreview() {
    if (this.previewLink) {
      this.previewLink.tab("show");
      this.instance.showPreview();
      this.options.onPostPreview();
    }
  }

  localize() {
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

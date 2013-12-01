
// Uploader view for the publisher.
// Initializes the file uploader plugin and handles callbacks for the upload
// progress. Attaches previews of finished uploads to the publisher.

app.views.PublisherUploader = Backbone.View.extend({

  allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'tif', 'tiff'],
  sizeLimit: 4194304,  // bytes

  initialize: function() {
    this.uploader = new qq.FileUploaderBasic({
      element: this.el,
      button:  this.el,

      //debug: true,

      action: '/photos',
      params: { photo: { pending: true }},
      allowedExtensions: this.allowedExtensions,
      sizeLimit: this.sizeLimit,
      messages: {
        typeError:  Diaspora.I18n.t('photo_uploader.invalid_ext'),
        sizeError:  Diaspora.I18n.t('photo_uploader.size_error'),
        emptyError: Diaspora.I18n.t('photo_uploader.empty')
      },
      onProgress: _.bind(this.progressHandler, this),
      onSubmit:   _.bind(this.submitHandler, this),
      onComplete: _.bind(this.uploadCompleteHandler, this)

    });

    this.el_info = $('<div id="fileInfo" />');
    this.options.publisher.el_wrapper.before(this.el_info);

    this.options.publisher.el_photozone.on('click', '.x', _.bind(this._removePhoto, this));
  },

  progressHandler: function(id, fileName, loaded, total) {
    var progress = Math.round(loaded / total * 100);
    this.el_info.text(fileName + ' ' + progress + '%').fadeTo(200, 1);
  },

  submitHandler: function(id, fileName) {
    this.$el.addClass('loading');
    this._addPhotoPlaceholder();
  },

  // add photo placeholders to the publisher to indicate an upload in progress
  _addPhotoPlaceholder: function() {
    var publisher = this.options.publisher;
    publisher.setButtonsEnabled(false);

    publisher.el_wrapper.addClass('with_attachments');
    publisher.el_photozone.append(
      '<li class="publisher_photo loading" style="position:relative;">' +
      '  <img src="'+Handlebars.helpers.imageUrl('ajax-loader2.gif')+'" alt="" />'+
      '</li>'
    );
  },

  uploadCompleteHandler: function(id, fileName, response) {
    if (response.success){
      this.el_info.text(Diaspora.I18n.t('photo_uploader.completed', {file: fileName})).fadeTo(2000, 0);

      var id  = response.data.photo.id,
          url = response.data.photo.unprocessed_image.url;

      this._addFinishedPhoto(id, url);
      this.trigger('change');
    } else {
      this._cancelPhotoUpload();
      this.trigger('change');
      this.el_info.text(Diaspora.I18n.t('photo_uploader.error', {file: fileName}));
    }
  },

  // replace the first photo placeholder with the finished uploaded image and
  // add the id to the publishers form
  _addFinishedPhoto: function(id, url) {
    var publisher = this.options.publisher;

    // add form input element
    publisher.$('.content_creation form').append(
      '<input type="hidden", value="'+id+'" name="photos[]" />'
    );

    // replace placeholder
    var placeholder = publisher.el_photozone.find('li.loading').first();
    placeholder
      .removeClass('loading')
      .append(
        '<div class="x">X</div>'+
        '<div class="circle"></div>'
       )
      .find('img').attr({'src': url, 'data-id': id});

    // no more placeholders? enable buttons
    if( publisher.el_photozone.find('li.loading').length == 0 ) {
      this.$el.removeClass('loading');
      publisher.setButtonsEnabled(true);
    }
  },

  _cancelPhotoUpload: function() {
    var publisher = this.options.publisher;
    var placeholder = publisher.el_photozone.find('li.loading').first();
    placeholder
      .removeClass('loading')
      .find('img').remove();
  },

  // remove an already uploaded photo
  _removePhoto: function(evt) {
    var self  = this;
    var photo = $(evt.target).parents('.publisher_photo')
    var img   = photo.find('img');

    photo.addClass('dim');
    $.ajax({
      url: '/photos/'+img.attr('data-id'),
      dataType: 'json',
      type: 'DELETE',
      success: function() {
        $.when(photo.fadeOut(400)).then(function(){
          photo.remove();

          if( self.options.publisher.$('.publisher_photo').length == 0 ) {
            // no more photos left...
            self.options.publisher.el_wrapper.removeClass('with_attachments');
          }

          self.trigger('change');
        });
      }
    });

    return false;
  }

});

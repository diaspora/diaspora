/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

//TODO: make this a widget
var Publisher = {
  bookmarklet : false,
  close: function(){
    Publisher.form().addClass('closed');
    Publisher.form().find("#publisher_textarea_wrapper").removeClass('active');
    Publisher.form().find("textarea.ac_input").css('min-height', '');
  },
  open: function(){
    Publisher.form().removeClass('closed');
    Publisher.form().find("#publisher_textarea_wrapper").addClass('active');
    Publisher.form().find("textarea.ac_input").css('min-height', '42px');
    Publisher.determineSubmitAvailability();
  },
  cachedForm : false,
  form: function(){
    if(!Publisher.cachedForm){
      Publisher.cachedForm = $('#publisher');
    }
    return Publisher.cachedForm;
  },
  cachedInput : false,
  input: function(){
    if(!Publisher.cachedInput){
      Publisher.cachedInput = Publisher.form().find('#status_message_fake_text');
    }
    return Publisher.cachedInput;
  },

  cachedHiddenInput : false,
  hiddenInput: function(){
    if(!Publisher.cachedHiddenInput){
      Publisher.cachedHiddenInput = Publisher.form().find('#status_message_text');
    }
    return Publisher.cachedHiddenInput;
  },

  cachedSubmit : false,
  submit: function(){
    if(!Publisher.cachedSubmit){
      Publisher.cachedSubmit = Publisher.form().find('#status_message_submit');
    }
    return Publisher.cachedSubmit;
  },

  autocompletion: {
    options : function(){return {
      minChars : 1,
      max : 5,
      onSelect : Publisher.autocompletion.onSelect,
      searchTermFromValue: Publisher.autocompletion.searchTermFromValue,
      scroll : false,
      formatItem: function(row, i, max) {
          return "<img src='"+ row.avatar +"' class='avatar'/>" + row.name;
      },
      formatMatch: function(row, i, max) {
          return row.name;
      },
      formatResult: function(row) {
          return row.name;
      },
      disableRightAndLeft : true
    };},
    hiddenMentionFromPerson : function(personData){
      return "@{" + personData.name + "; " + personData.handle + "}";
    },

    onSelect :  function(visibleInput, data, formatted) {
      var visibleCursorIndex = visibleInput[0].selectionStart;
      var visibleLoc = Publisher.autocompletion.addMentionToInput(visibleInput, visibleCursorIndex, formatted);
      $.Autocompleter.Selection(visibleInput[0], visibleLoc[1], visibleLoc[1]);

      var mentionString = Publisher.autocompletion.hiddenMentionFromPerson(data);
      var mention = { visibleStart: visibleLoc[0],
                      visibleEnd  : visibleLoc[1],
                      mentionString : mentionString
                    };
      Publisher.autocompletion.mentionList.push(mention);
      Publisher.oldInputContent = visibleInput.val();
      Publisher.hiddenInput().val(Publisher.autocompletion.mentionList.generateHiddenInput(visibleInput.val()));
    },

    mentionList : {
      mentions : [],
      sortedMentions : function(){
        return this.mentions.sort(function(m1, m2){
          if(m1.visibleStart > m2.visibleStart){
            return -1;
          } else if(m1.visibleStart < m2.visibleStart){
            return 1;
          } else {
            return 0;
          }
        });
      },
      push : function(mention){
        this.mentions.push(mention);
      },
      generateHiddenInput : function(visibleString){
        var resultString = visibleString;
        for(var i in this.sortedMentions()){
          var mention = this.mentions[i];
          var start = resultString.slice(0, mention.visibleStart);
          var insertion = mention.mentionString;
          var end = resultString.slice(mention.visibleEnd);

          resultString = start + insertion + end;
        }
        return resultString;
      },

      insertionAt : function(insertionStartIndex, selectionEnd, keyCode){
        if(insertionStartIndex != selectionEnd){
          this.selectionDeleted(insertionStartIndex, selectionEnd);
        }
        this.updateMentionLocations(insertionStartIndex, 1);
        this.destroyMentionAt(insertionStartIndex);
      },
      deletionAt : function(selectionStart, selectionEnd, keyCode){
        if(selectionStart != selectionEnd){
          this.selectionDeleted(selectionStart, selectionEnd);
          return;
        }

        var effectiveCursorIndex;
        if(keyCode == KEYCODES.DEL){
          effectiveCursorIndex = selectionStart;
        }else{
          effectiveCursorIndex = selectionStart - 1;
        }
        this.updateMentionLocations(effectiveCursorIndex, -1);
        this.destroyMentionAt(effectiveCursorIndex);
      },
      selectionDeleted : function(selectionStart, selectionEnd){
        Publisher.autocompletion.mentionList.destroyMentionsWithin(selectionStart, selectionEnd);
        Publisher.autocompletion.mentionList.updateMentionLocations(selectionStart, selectionStart - selectionEnd);
      },
      destroyMentionsWithin : function(start, end){
        for (var i = this.mentions.length - 1; i >= 0; i--){
          var mention = this.mentions[i];
          if(start < mention.visibleEnd && end >= mention.visibleStart){
            this.mentions.splice(i, 1);
          }
        }
      },
      clear: function(){
        this.mentions = [];
      },
      destroyMentionAt : function(effectiveCursorIndex){

        var mentionIndex = this.mentionAt(effectiveCursorIndex);
        var mention = this.mentions[mentionIndex];
        if(mention){
          this.mentions.splice(mentionIndex, 1);
        }
      },
      updateMentionLocations : function(effectiveCursorIndex, offset){
        var changedMentions = this.mentionsAfter(effectiveCursorIndex);
        for(var i in changedMentions){
          var mention = changedMentions[i];
          mention.visibleStart += offset;
          mention.visibleEnd += offset;
        }
      },
      mentionAt : function(visibleCursorIndex){
        for(var i in this.mentions){
          var mention = this.mentions[i];
          if(visibleCursorIndex > mention.visibleStart && visibleCursorIndex < mention.visibleEnd){
            return i;
          }
        }
        return false;
      },
      mentionsAfter : function(visibleCursorIndex){
        var resultMentions = [];
        for(var i in this.mentions){
          var mention = this.mentions[i];
          if(visibleCursorIndex <= mention.visibleStart){
            resultMentions.push(mention);
          }
        }
        return resultMentions;
      }
    },
    repopulateHiddenInput: function(){
      var newHiddenVal = Publisher.autocompletion.mentionList.generateHiddenInput(Publisher.input().val());
      if(newHiddenVal != Publisher.hiddenInput().val()){
        Publisher.hiddenInput().val(newHiddenVal);
      }
    },

    keyUpHandler : function(event){
      Publisher.autocompletion.repopulateHiddenInput();
      Publisher.determineSubmitAvailability();
    },

    keyDownHandler : function(event){
      var input = Publisher.input();
      var selectionStart = input[0].selectionStart;
      var selectionEnd = input[0].selectionEnd;
      var isDeletion = (event.keyCode == KEYCODES.DEL && selectionStart < input.val().length) || (event.keyCode == KEYCODES.BACKSPACE && (selectionStart > 0 || selectionStart != selectionEnd));
      var isInsertion = (KEYCODES.isInsertion(event.keyCode) && event.keyCode != KEYCODES.RETURN );

      if(isDeletion){
        Publisher.autocompletion.mentionList.deletionAt(selectionStart, selectionEnd, event.keyCode);
      }else if(isInsertion){
        Publisher.autocompletion.mentionList.insertionAt(selectionStart, selectionEnd, event.keyCode);
      }
    },

    addMentionToInput: function(input, cursorIndex, formatted){
      var inputContent = input.val();

      var stringLoc = Publisher.autocompletion.findStringToReplace(inputContent, cursorIndex);

      var stringStart = inputContent.slice(0, stringLoc[0]);
      var stringEnd = inputContent.slice(stringLoc[1]);

      input.val(stringStart + formatted + stringEnd);
      var offset = formatted.length - (stringLoc[1] - stringLoc[0]);
      Publisher.autocompletion.mentionList.updateMentionLocations(stringStart.length, offset);
      return [stringStart.length, stringStart.length + formatted.length];
    },

    findStringToReplace: function(value, cursorIndex){
      var atLocation = value.lastIndexOf('@', cursorIndex);
      if(atLocation == -1){return [0,0];}
      var nextAt = cursorIndex;

      if(nextAt == -1){nextAt = value.length;}
      return [atLocation, nextAt];

    },

    searchTermFromValue: function(value, cursorIndex)
    {
      var stringLoc = Publisher.autocompletion.findStringToReplace(value, cursorIndex);
      if(stringLoc[0] <= 2){
        stringLoc[0] = 0;
      }else{
        stringLoc[0] -= 2;
      }

      var relevantString = value.slice(stringLoc[0], stringLoc[1]).replace(/\s+$/,"");

      var matches = relevantString.match(/(^|\s)@(.+)/);
      if(matches){
        return matches[2];
      }else{
        return '';
      }
    },
    initialize: function(){
      $.getJSON($("#publisher .selected_contacts_link").attr("href"), undefined ,
        function(data){
          Publisher.input().autocomplete(data,
            Publisher.autocompletion.options());
          Publisher.input().result(Publisher.autocompletion.selectItemCallback);
          Publisher.oldInputContent = Publisher.input().val();
        }
      );
    }
  },
  determineSubmitAvailability: function(){
    var onlyWhitespaces = (Publisher.input().val().trim() === '');
    var isSubmitDisabled = Publisher.submit().attr('disabled');
    var isPhotoAttached = ($("#photodropzone").children().length > 0);
    if ((onlyWhitespaces &&  !isPhotoAttached) && !isSubmitDisabled) {
      Publisher.submit().attr('disabled', true);
    } else if ((!onlyWhitespaces || isPhotoAttached) && isSubmitDisabled) {
      Publisher.submit().removeAttr('disabled');
    }
  },
  clear: function(){
    this.autocompletion.mentionList.clear();
    $("#photodropzone").find('li').remove();
    $("#publisher textarea").removeClass("with_attachments").css('paddingBottom', '');
  },
  bindServiceIcons: function(){
    $(".service_icon").bind("click", function(evt){
      $(this).toggleClass("dim");
      Publisher.toggleServiceField($(this));
    });
  },
  bindPublicIcon: function(){
    $(".public_icon").bind("click", function(evt){
      $(this).toggleClass("dim");
      var public_field = $("#publisher #status_message_public");

      if (public_field.val() == 'false') {
        public_field.val('true');
        $(this).attr('title', Diaspora.I18n.t('publisher.public'));
      } else {
        public_field.val('false');
        $(this).attr('title', Diaspora.I18n.t('publisher.limited'));
      }

      $(this).tipsy(true).fixTitle();
      $(this).tipsy(true).show();
    });
  },
  toggleServiceField: function(service){
    Publisher.createCounter(service);

    var provider = service.attr('id');
    var hidden_field = $('#publisher [name="services[]"][value="'+provider+'"]');
    if(hidden_field.length > 0){
      hidden_field.remove();
    } else {
      $("#publisher .content_creation form").append(
      '<input id="services_" name="services[]" type="hidden" value="'+provider+'">');
    }
  },
  selectedAspectIds: function() {
    var aspects = $('#publisher [name="aspect_ids[]"]');
    var aspectIds = [];
    aspects.each(function() { aspectIds.push( parseInt($(this).attr('value'))); });
    return aspectIds;
  },
  toggleAspectIds: function(aspectId) {
    var hidden_field = $('#publisher [name="aspect_ids[]"][value="'+aspectId+'"]');
    if(hidden_field.length > 0){
      hidden_field.remove();
    } else {
      $("#publisher .content_creation form").append(
      '<input id="aspect_ids_" name="aspect_ids[]" type="hidden" value="'+aspectId+'">');
    }
  },
  createCounter: function(service){
    var counter = $("#publisher .counter");
    counter.remove();

    var min = 40000;
    var a = $('.service_icon:not(.dim)');
    if(a.length > 0){
      $.each(a, function(index, value){
        var num = parseInt($(value).attr('maxchar'));
        if (min > num) { min = num; }
      });
      $('#status_message_fake_text').charCount({allowed: min, warning: min/10 });
    }
  },
  bindAspectToggles: function() {
    $('#publisher .dropdown .dropdown_list li').bind("click", function(evt){
      var li = $(this),
          button = li.parent('.dropdown').find('.button');

      AspectsDropdown.toggleCheckbox(li);
      AspectsDropdown.updateNumber(li.closest(".dropdown_list"), null, li.parent().find('li.selected').length, '');

      Publisher.toggleAspectIds(li.attr('data-aspect_id'));
    });
  },
  beforeSubmit: function(){
    if($("#publisher .content_creation form #aspect_ids_").length == 0){
      alert(Diaspora.I18n.t('publisher.at_least_one_aspect'));
      return false;
    }
    $('#preview').addClass('dim');
    Publisher.hidePreview();
  },
  onSubmit: function(data, json, xhr){
    $("#photodropzone").find('li').remove();
    $("#publisher textarea").removeClass("with_attachments").css('paddingBottom', '');
  },
  onFailure: function(data, json, xhr){
    $('#preview').removeClass('dim');
    json = $.parseJSON(json.responseText);
    if(json.errors.length !== 0){
      Diaspora.Alert.show(json.errors);
    }else{
      Diaspora.Alert.show(Diaspora.I18n.t('failed_to_post_message'));
    }
  },
  onSuccess: function(data, json, xhr){
    if (Publisher.bookmarklet == false) {
      var isPostVisible = Diaspora.page.aspectNavigation.selectedAspects().length == 0;
      var postedTo = Publisher.selectedAspectIds();
      $.each(Diaspora.page.aspectNavigation.selectedAspects(), function(index, value) {
        if (postedTo.indexOf(parseInt(value)) > -1)
          isPostVisible = true;
      });

      if(isPostVisible) {
        ContentUpdater.addPostToStream(json.html);
        Diaspora.page.stream.addPost($("#" + json.post_id));
      }
      else {
        Diaspora.widgets.flashMessages.render({
          success: true,
          message: Diaspora.I18n.t('successfully_posted_message_to_an_aspects_that_is_not_visible')
        });
      }
    }
    $('#preview').removeClass('dim');
    //collapse publisher
    Publisher.close();
    Publisher.clear();
    //Stream.setUpImageLinks();
    Stream.setUpAudioLinks();
  },
  bindAjax: function(){
    Publisher.form().bind('submit', Publisher.beforeSubmit);
    Publisher.form().bind('ajax:loading', Publisher.onSubmit);
    Publisher.form().bind('ajax:failure', Publisher.onFailure);
    Publisher.form().bind('ajax:success', Publisher.onSuccess);
  },
  hidePreview: function() {
    $('#preview-edit').hide();
    $('#preview-result').hide();
    $('#preview').show();
    $('#publisher_textarea_wrapper').show();
    $('#file-upload').show();
  },
  initialize: function() {
    Publisher.cachedForm = Publisher.cachedSubmit =
      Publisher.cachedInput = Publisher.cachedHiddenInput = false;

    Publisher.bindServiceIcons();
    Publisher.bindPublicIcon();
    Publisher.bindAspectToggles();

    /* close text area */
    Publisher.form().delegate("#hide_publisher", "click", function(){
      $.each(Publisher.form().find("textarea"), function(idx, element){
        $(element).val("");
      });
      Publisher.close();
    });

    Publisher.autocompletion.initialize();
    Publisher.hiddenInput().val(Publisher.input().val());
    Publisher.input().autoResize();
    Publisher.input().keydown(Publisher.autocompletion.keyDownHandler);
    Publisher.input().keyup(Publisher.autocompletion.keyUpHandler);
    Publisher.bindAjax();
    Publisher.form().find("textarea").bind("focus", function(evt) {
      Publisher.open();
    });

    $('#preview.button:not(.dim)').live( 'click', function(evt) {
      evt.preventDefault();

      $('#preview').addClass('dim');

      $.post('/preview.json', {
        text: $('#status_message_fake_text').val()
      }, function(data){
        $('#preview').hide();
        $('#publisher_textarea_wrapper').hide();
        $('#preview-edit').show();

        $('#preview-result')
          /* explicit height so that scrollbars appear when needed */
          .height( $('#publisher_textarea_wrapper').height() - 24 )
          .width( $('#publisher_textarea_wrapper').width() - 4 )
          .html( data.result )
          .show()
        ;

        $('#file-upload').hide();
      });
    } );

    $('#preview-edit').live( 'click', function(evt) {
      evt.preventDefault();
      $('#preview').removeClass('dim');
      Publisher.hidePreview();
    } );
  }
};

$(document).ready(function() {
  Publisher.initialize();
  Diaspora.page.subscribe("stream/reloaded", Publisher.initialize);
});

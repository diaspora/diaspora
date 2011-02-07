/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

//TODO: make this a widget
var Publisher = {
  close: function(){
    Publisher.form().addClass('closed');
    Publisher.form().find(".options_and_submit").hide();
         },
  open: function(){
    Publisher.form().removeClass('closed');
    Publisher.form().find(".options_and_submit").show();
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
      Publisher.cachedInput = Publisher.form().find('#status_message_fake_message');
    }
    return Publisher.cachedInput;
  },

  cachedHiddenInput : false,
  hiddenInput: function(){
    if(!Publisher.cachedHiddenInput){
      Publisher.cachedHiddenInput = Publisher.form().find('#status_message_message');
    }
    return Publisher.cachedHiddenInput;
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
      }
    };},
    hiddenMentionFromPerson : function(personData){
      return "@{" + personData.name + "; " + personData.handle + "}";
    },

    onSelect :  function(visibleInput, data, formatted) {
      var visibleCursorIndex = visibleInput[0].selectionStart;
      var visibleLoc = Publisher.autocompletion.addMentionToInput(visibleInput, visibleCursorIndex, formatted);
      $.Autocompleter.Selection(visibleInput[0], visibleLoc[1], visibleLoc[1]);

      var hiddenCursorIndex = visibleCursorIndex + Publisher.autocompletion.mentionList.offsetFrom(visibleCursorIndex);
      var hiddenLoc = Publisher.autocompletion.addMentionToInput(Publisher.hiddenInput(), hiddenCursorIndex, Publisher.autocompletion.hiddenMentionFromPerson(data));
      var mention = { visibleStart: visibleLoc[0],
                      visibleEnd  : visibleLoc[1],
                      hiddenStart : hiddenLoc[0],
                      hiddenEnd   : hiddenLoc[1]
                    };
    },

    mentionList : {
      mentions : [],
      push : function(mention){
        mention.offset = mention.hiddenEnd - mention.visibleEnd;
        this.mentions.push(mention);
      },
      keypressAt : function(visibleCursorIndex){
        var mentionIndex = this.mentionAt(visibleCursorIndex);
        var mention = this.mentions[mentionIndex];
        if(!mention){return;}
        var visibleMentionString = Publisher.input().val().slice(mention.visibleStart, mention.visibleEnd);
        var hiddenContent = Publisher.hiddenInput().val();
        hiddenContent = hiddenContent.slice(0,mention.hiddenStart) +
                        visibleMentionString +
                        hiddenContent.slice(mention.hiddenEnd);
        Publisher.hiddenInput().val(hiddenContent);

        this.mentions.splice(mentionIndex, 1);
      },
      mentionAt : function(visibleCursorIndex){
        for(i in this.mentions){
          var mention = this.mentions[i];
          if(visibleCursorIndex >= mention.visibleStart && visibleCursorIndex < mention.visibleEnd){
            return i;
          }
          return false;
        }
      },
      offsetFrom: function(visibleCursorIndex){
        var mention = {visibleStart : -1, fake: true};
        var currentMention;
        for(i in this.mentions){
          currentMention = this.mentions[i];
          if(visibleCursorIndex >= currentMention.visibleStart &&
             currentMention.visibleStart > mention.visibleStart){
             mention = currentMention;
          }
        }
        if(mention && !mention.fake){
          return mention.offset;
        }else{
          return 0;
        }
      }
    },

    addMentionToInput: function(input, cursorIndex, formatted){
      var inputContent = input.val();

      var stringLoc = Publisher.autocompletion.findStringToReplace(input.val(), cursorIndex);

      var stringStart = inputContent.slice(0, stringLoc[0]);
      var stringEnd = inputContent.slice(stringLoc[1]);

      input.val(stringStart + formatted + stringEnd);
      return [stringStart.length, stringStart.length + formatted.length]
    },

    findStringToReplace: function(value, cursorIndex){
      var atLocation = value.lastIndexOf('@', cursorIndex);
      if(atLocation == -1){return [0,0];}
      var nextAt = cursorIndex//value.indexOf(' @', cursorIndex+1);

      if(nextAt == -1){nextAt = value.length;}
      return [atLocation, nextAt];

    },

    searchTermFromValue: function(value, cursorIndex)
    {
      var stringLoc = Publisher.autocompletion.findStringToReplace(value, cursorIndex);
      if(stringLoc[0] <= 2){
        stringLoc[0] = 0;
      }else{
        stringLoc[0] -= 2
      }

      var relevantString = value.slice(stringLoc[0], stringLoc[1]).replace(/\s+$/,"");

      var matches = relevantString.match(/(^|\s)@(.+)/);
      if(matches){
        return matches[2];
      }else{
        return '';
      }
    },
    contactsJSON: function(){
      return $.parseJSON($('#contact_json').val());
    },
    initialize: function(){
      Publisher.input().autocomplete(Publisher.autocompletion.contactsJSON(),
        Publisher.autocompletion.options());
      Publisher.input().result(Publisher.autocompletion.selectItemCallback);
    }
  },
  initialize: function() {
    Publisher.cachedForm = false;
    Publisher.cachedInput = false;
    Publisher.cachedHiddenInput = false;
    $("div.public_toggle input").live("click", function(evt) {
      $("#publisher_service_icons").toggleClass("dim");
      if ($(this).attr('checked') == true) {
        $(".question_mark").click();
      }
    });

    if ($("#status_message_fake_message").val() == "") {
      Publisher.close();
    };

    Publisher.autocompletion.initialize();
    Publisher.hiddenInput().val(Publisher.input().val());
    Publisher.form().find("textarea").bind("focus", function(evt) {
      Publisher.open();
      $(this).css('min-height', '42px');
    });
  }
};

$(document).ready(function() {
  Publisher.initialize();
});

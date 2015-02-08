// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.PublisherPollCreator = app.views.Base.extend({
  templateName: "poll_creator",
  
  events: {
    'keypress input:last': 'addAnswer',
    'click .remove-answer': 'removeAnswer',
    'blur input': 'validate',
    'input input': 'validate'
  },

  postRenderTemplate: function(){
    this.$pollAnswers = this.$('.poll-answers');
    this.inputCount = 2;
    this.trigger('change');
    this.bind('publisher:sync', this.render, this);
  },

  addAnswer: function(evt){
    if (!$(evt.target).val()) {
      this.addAnswerInput();
    }
  },
  
  addAnswerInput: function(){
    this.inputCount++;
    var input_wrapper = this.$('.poll-answer:first').clone();
    var input = input_wrapper.find('input');

    input.attr('placeholder', Diaspora.I18n.t('publisher.add_option'));
    input.val('');
    this.$pollAnswers.append(input_wrapper);
    this.toggleRemoveAnswer();
  },

  removeAnswer: function(evt){
    evt.stopPropagation();
    this.removeAnswerInput(this.$(evt.target));
    this.trigger('change');
  },

  removeAnswerInput: function(input){
    input.parents('.poll-answer').remove();
    this.toggleRemoveAnswer();
  },

  removeLastAnswer: function (){
    var inputs = this.$pollAnswers.find('input');
    if(inputs.length > 2 && !inputs[inputs.length - 1].value) {
      this.$el.find('.poll-answer:last').remove();
    }
  },

  toggleRemoveAnswer: function(){
    var inputs = this.$pollAnswers.find('input');
    if(inputs.length < 3){
      this.$('.remove-answer').removeClass('active');
    }
    else {
      this.$('.remove-answer').addClass('active');
    }
  },

  clearInputs: function(){
    this.$('input').val('');
  },

  validate: function(){
    this.validatePoll();
    this.trigger('change');
  },

  validateInput: function(input){
    var isValid = this.isValidInput(input);

    if(isValid){
      input.removeClass('error');
      return true;
    }
    else {
      input.addClass('error');
      return false;
    }
  },

  isValidInput: function(input){
    return $.trim(input.val());
  },

  validatePoll: function() {
    var _this = this;
    var inputs = this.$('input:visible');
    var pollValid = true;

    _.each(inputs, function(input, i){
      // Validate the input unless it is the last one, or there are only the
      // question field and two options
      if( i !== inputs.length - 1 || inputs.length <= 3) {
        if(_this.validateInput($(input)) === false) pollValid = false;
      }      
    });

    return pollValid;
  }
});
// @license-end


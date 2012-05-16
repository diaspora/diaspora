/**
 * @author Justin Thomas
 */

jQuery(function($) {
	window.vc = new view_controller()

	$("#entropy-div").hide()		
	//$("#instruction").text("Encryption and signing keys are in place.")
		
	if(window.current_user_attributes.key_ring) {
		$("#entropy-div").show()
		
		$(window).bind('mousemove', window.vc.collect)
		sjcl.random.startCollectors()
	}
})

function view_controller() {"use strict"

	if(!(this instanceof view_controller))
		throw new Error("Constructor called as a function")

	this.crypto = new crypto()
	this.keys = {}

	this.collect = function() {
		var progress = sjcl.random.getProgress(10)

		if(progress === undefined || progress == 1) {
			$("#entropy").text("100%")
			sjcl.random.stopCollectors()
			$(window).unbind('mousemove', window.vc.collect)
			$("#entropy-div").hide()
			//$("#instruction").hide()
		} else {
			var percentage = progress * 100;
			$("#entropy").text(percentage.toFixed(0) + "%")
		}
	}
	
	this.encrypt_message = function(event) {		
		var msg = this.crypto.prepare_message(
			$("#as-values-contact_ids").val(), 
			$("#passphrase").val(), 
			$("#conversation_text").val(), 
			$("#conversation_subject").val())
		
		$("#conversation_text").val(Base64.encode(JSON.stringify(msg)))
		$("#conversation_subject").val("encrypted")
				
		return true
	}
}
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
		var form = event.target
		
		var text, subject, contacts, people, passphrase
		
		passphrase = $("#passphrase").val()
		
		if(form.id == "new_message") {
			text = $("#message_text").val()
			var people_ids = []
			
			$(".conversation_participants .avatar").each( 
				function(index) { people_ids.push($(this).attr("data-person_id")) 
			})
			
			people = people_ids.join(",")
		} else {
			text = $("#conversation_text").val()
			subject = $("#conversation_subject").val()
			contacts = $("#as-values-contact_ids").val()
		}
		
		var msg = this.crypto.prepare_message(contacts,people,passphrase,text,subject)
		
		if(form.id == "new_message") {
			$("#message_text").val(Base64.encode(JSON.stringify(msg)))
		} else {
			$("#conversation_text").val(Base64.encode(JSON.stringify(msg)))
			$("#conversation_subject").val("encrypted")
		}
				
		return true
	}
}
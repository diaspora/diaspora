/**
 * @author Justin Thomas
 */

jQuery(function($) {
	window.vc = new view_controller()

	$("#entropy-div").hide()		
		
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
	
	this.decrypt_conversations = function() {
		$('#conversation_show .ltr p').each(function(index) {
			var msg
			
			try {
				msg = JSON.parse(Base64.decode($(this).text()))
			} catch (e) {
				return true
			}
			
			var sec = JSON.parse(sjcl.decrypt($("#passphrase").val(), window.current_user_attributes.key_ring.key_ring.secured_encryption_key))
			var bn = sjcl.bn.fromBits(sec.exponent)
			sec = new sjcl.ecc.elGamal.secretKey(sec.curve, sjcl.ecc.curves['c'+sec.curve], bn)
			
			var sym = JSON.parse(sjcl.decrypt(sec, msg.message_keys[window.current_user_attributes.key_ring.key_ring.person_id]))
			var message = sjcl.decrypt(sym, msg.encrypted_message)
			
			var subject
			try {
				subject = sjcl.decrypt(sym, msg.encrypted_subject)
			} catch (e) {
				// do nothing
			}
			
			$(this).text(message)
			
			if(subject) {
				$("#conversation_inbox .conversation .selected .ltr").text(subject)
			}
		})
	}
}
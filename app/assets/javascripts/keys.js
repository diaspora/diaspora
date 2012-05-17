
jQuery(function($) {
	var vc = new view_controller()

	$("#passphrase-div").hide()
	$("#generate-keys").hide()
	$("#entropy-div").hide()		
	$("#instruction").text("Encryption and signing keys are in place.")
		
	if(!window.current_user_attributes.key_ring) {
		$("#instruction").text("Move mouse to generate entropy.")
		$("#entropy-div").show()
		
		$(window).bind('mousemove', vc.collect)
		sjcl.random.startCollectors()
	
		$("#generate-keys").bind('click', function(event) {
			var keys = vc.crypto.generate_keys()
			vc.keys = vc.crypto.encrypt_keys($("#passphrase").val(), keys)
			console.log(keys)
			vc.store_keys(event)
		})
	} 
})
function view_controller() {"use strict"

	if(!(this instanceof view_controller))
		throw new Error("Constructor called as a function")

	var vc = this

	this.crypto = new crypto()
	this.keys = {}

	this.collect = function() {
		var progress = sjcl.random.getProgress(10)

		if(progress === undefined || progress == 1) {
			$("#entropy").text("100%")
			sjcl.random.stopCollectors()
			$(window).unbind('mousemove', vc.collect)
			vc.keys = vc.crypto.generate_keys()
			$("#passphrase-div").show()
			$("#entropy-div").hide()
			$("#passphrase").focus()
			$("#generate-keys").show()
			$("#instruction").hide()
		} else {
			var percentage = progress * 100;
			$("#entropy").text(percentage.toFixed(0) + "%")
		}
	}

	this.store_keys = function(event) {
		if(!$("#passphrase").val() || !vc.keys) {
			console.log("passphrase and full entropy are required")
			event.preventDefault()
			return false
		}
		
		$("#secured_encryption_key").val(vc.keys.encryption.sec)
		$("#public_encryption_key").val(JSON.stringify(vc.keys.encryption.pub))
		$("#secured_signing_key").val(vc.keys.signing.sec)
		$("#public_verification_key").val(JSON.stringify(vc.keys.signing.pub))
		$("#guid").val(window.current_user_attributes.guid)
			
		$("#keys").submit()

		return true
	}
}


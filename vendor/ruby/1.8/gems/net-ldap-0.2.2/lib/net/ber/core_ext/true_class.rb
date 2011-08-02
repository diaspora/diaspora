# -*- ruby encoding: utf-8 -*-
##
# BER extensions to +true+.
module Net::BER::Extensions::TrueClass
  ##
  # Converts +true+ to the BER wireline representation of +true+.
  def to_ber
    # 20100319 AZ: Note that this may not be the completely correct value,
    # per some test documentation. We need to determine the truth of this.
    "\001\001\001"
  end
end

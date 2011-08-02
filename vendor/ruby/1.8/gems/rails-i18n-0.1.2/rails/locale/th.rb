# Thai translation for Ruby on Rails
# original by Prem Sichanugrist (s@sikachu.com/sikandsak@gmail.com)
# activerecord keys fixed by Jittat Fakcharoenphol (jittat@gmail.com)
#
# Note: You must install i18n gem in order to use this language pack.
# If you're calling I18n.localize(Time.now), the year will be in Bhuddhist calendar

# This is used to DRY up ActiveRecord validation messages
unless defined?(ThaiLocaleI18n::ERROR_MESSAGES)
  module ThaiLocaleI18n
    ERROR_MESSAGES = {
      :inclusion => "ไม่ได้อยู่ในรายการ",
      :exclusion => "ไม่ได้รับอนุญาตให้ใช้",
      :invalid => "ไม่ถูกต้อง",
      :confirmation => "ไม่ตรงกับการยืนยัน",
      :accepted => "ต้องถูกยอมรับ",
      :empty => "ต้องไม่เว้นว่างเอาไว้",
      :blank => "ต้องไม่เว้นว่างเอาไว้",
      :too_long => "ยาวเกินไป (ต้องไม่เกิน %{count} ตัวอักษร)",
      :too_short => "สั้นเกินไป (ต้องยาวกว่า %{count} ตัวอักษร)",
      :wrong_length => "มีความยาวไม่ถูกต้อง (ต้องมีความยาว %{count} ตัวอักษร)",
      :not_a_number => "ไม่ใช่ตัวเลข",
      :not_an_integer => "ไม่ใช่จำนวนเต็ม",
      :greater_than => "ต้องมากกว่า %{count}",
      :greater_than_or_equal_to => "ต้องมากกว่าหรือเท่ากับ %{count}",
      :equal_to => "ต้องมีค่าเท่ากับ %{count}",
      :less_than => "ต้องมีค่าน้อยกว่า %{count}",
      :less_than_or_equal_to => "ต้องมีค่าน้อยกว่าหรือเท่ากับ %{count}",
      :odd => "ต้องเป็นจำนวนคี่",
      :even => "ต้องเป็นจำนวนคู่",
    }
  end
end

{ :'th' => {

:date => {
  :formats => {
    :default => lambda { |date, opts| "%d-%m-#{date.year + 543}" },
    :short => "%d %b",
    :long => lambda { |date, opts| "%d %B #{date.year + 543}" },
  },

  :day_names => ["อาทิตย์", "จันทร์", "อังคาร", "พุธ", "พฤหัสบดี", "ศุกร์", "เสาร์"],
  :abbr_day_names => ["อา", "จ", "อ", "พ", "พฤ", "ศ", "ส"],

  :month_names => [nil, "มกราคม", "กุมภาพันธ์", "มีนาคม", "เมษายน", "พฤษภาคม", "มิถุนายน", "กรกฎาคม", "สิงหาคม", "กันยายน", "ตุลาคม", "พฤศจิกายน", "ธันวาคม"],
  :abbr_month_names => [nil, "ม.ค.", "ก.พ.", "มี.ค.", "เม.ย.", "พ.ค.", "มิ.ย.", "ก.ค.", "ส.ค.", "ก.ย.", "ต.ค.", "พ.ย.", "ธ.ค."],
  :order => [:day, :month, :year]
},

:time => {
  :formats => {
    :default => lambda { |date, opts| "%a %d %b #{date.year + 543} %H:%M:%S %z" },
    :short => "%d %b %H:%M น.",
    :long => lambda { |date, opts| "%d %B #{date.year + 543} %H:%M น." },
  },
  :am => "ก่อนเที่ยง",
  :pm => "หลังเที่ยง"
},

:support => {
  :array => {
    :words_connector => ", ",
    :two_words_connector => " และ ",
    :last_word_connector => ", และ ",
  },

  :select => {
    :prompt => "โปรดเลือก"
  }
},

:number => {
  :format => {
    :separator => ".",
    :delimiter => ",",
    :precision => 3,
    :significant => false,
    :strip_insignificant_zeros => false
  },

  :currency => {
    :format => {
      :format => "%n %u",
      :unit => "บาท",
      :separator => ".",
      :delimiter => ",",
      :precision => 2,
      :significant => false,
      :strip_insignificant_zeros => false
    }
  },

  :percentage => {
    :format => {
      :delimiter => "",
    }
  },

  :precision => {
    :format => {
      :delimiter => "",
    }
  },

  :human => {
    :format => {
      :delimiter => "",
      :precision => 3,
      :significant => true,
      :strip_insignificant_zeros => true
    },
    :storage_units => {
      :format => "%n %u",
      :units => {
        :byte => "ไบต์",
        :kb => "กิโลไบต์",
        :mb => "เมกะไบต์",
        :gb => "จิกะไบต์",
        :tb => "เทระไบต์"
      }
    },

    :decimal_units => {
      :format => "%n %u",
      :units => {
        :unit => "",
        :thousand => "พัน",
        :million => "ล้าน",
        :billion => "พันล้าน",
        :trillion => "ล้านล้าน",
        :quadrillion => "พันล้านล้าน"
      }
    }
  }
},

:datetime => {
  :distance_in_words => {
    :half_a_minute => "ครึ่งนาที",
    :less_than_x_seconds => "น้อยกว่า %{count} วินาที",
    :x_seconds => "%{count} วินาที",
    :less_than_x_minutes => "น้อยกว่า %{count} นาที",
    :x_minutes => "%{count} นาที",
    :about_x_hours => "ประมาณ %{count} ชั่วโมง",
    :x_days => "%{count} วัน",
    :about_x_months => "ประมาณ %{count} เดือน",
    :x_months => "%{count} เดือน",
    :about_x_years => "ประมาณ %{count} ปี",
    :over_x_years => "มากกว่า %{count} ปี",
    :almost_x_years => "เกือบ %{count} ปี",
  },
  :prompts => {
    :year =>   "ปี",
    :month =>  "เดือน",
    :day =>    "วัน",
    :hour =>   "ชั่วโมง",
    :minute => "นาที",
    :second => "วินาที",
  }
},

:helpers => {
  :select => {
    :prompt => "โปรดเลือก"
  },

  :submit => {
    :create => "สร้าง%{model}",
    :update => "ปรับปรุง%{model}",
    :submit => "บันทึก%{model}"
  }
},

:errors => {
  :format => "%{attribute} %{message}",
  :messages => ThaiLocaleI18n::ERROR_MESSAGES
},

:activerecord => {
  :errors => {
    :template => {
      :header => "พบข้อผิดพลาด %{count} ประการ ทำให้ไม่สามารถบันทึก%{model}ได้",
      :body => "โปรดตรวจสอบข้อมูลในช่องต่อไปนี้:"
    },

    :messages => {
      :taken => "ถูกใช้ไปแล้ว",
      :record_invalid => "ไม่ผ่านการตรวจสอบ: %{errors}"
    }.merge(ThaiLocaleI18n::ERROR_MESSAGES),

    :full_messages => {
      :format => "%{attribute} %{message}"
    },
  }
}

}}

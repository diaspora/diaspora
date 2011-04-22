# Czech translations for Ruby on Rails
# by Karel Minařík (karmi@karmi.cz)
# contributors:
#  - Vít Krchov - http://github.com/vita - Rails 3 update

unless defined?(CzechLocaleI18n::ERROR_MESSAGES)
  module CzechLocaleI18n
    ERROR_MESSAGES = {
      :inclusion           => "není v seznamu povolených hodnot",
      :exclusion           => "je vyhrazeno pro jiný účel",
      :invalid             => "není platná hodnota",
      :confirmation        => "nebylo potvrzeno",
      :accepted            => "musí být potvrzeno",
      :empty               => "nesmí být prázdný/é",
      :blank               => "je povinná položka", # alternate formulation: "is required"
      :too_long            => "je příliš dlouhá/ý (max. %{count} znaků)",
      :too_short           => "je příliš krátký/á (min. %{count} znaků)",
      :wrong_length        => "nemá správnou délku (očekáváno %{count} znaků)",
      :not_a_number        => "není číslo",
      :greater_than        => "musí být větší než %{count}",
      :greater_than_or_equal_to => "musí být větší nebo rovno %{count}",
      :equal_to            => "musí být rovno %{count}",
      :less_than           => "musí být méně než %{count}",
      :less_than_or_equal_to    => "musí být méně nebo rovno %{count}",
      :odd                 => "musí být liché číslo",
      :even                => "musí být sudé číslo",
      :not_an_integer       => "musí být celé číslo"
    }
  end
end

{ :'cs' => {

    # ActiveSupport
    :support => {
      :array => {
        :two_words_connector => ' a ',
        :last_word_connector => ' a ',
        :words_connector => ', '
      },
      :select => {
        :prompt => 'Prosím vyberte si',
      }
    },

    # Date
    :date => {
      :formats => {
        :default => "%d. %m. %Y",
        :short   => "%d %b",
        :long    => "%d. %B %Y",
      },
      :day_names         => %w{Neděle Pondělí Úterý Středa Čtvrtek Pátek Sobota},
      :abbr_day_names    => %w{Ne Po Út St Čt Pá So},
      :month_names       => %w{~ Leden Únor Březen Duben Květen Červen Červenec Srpen Září Říjen Listopad Prosinec},
      :abbr_month_names  => %w{~ Led Úno Bře Dub Kvě Čvn Čvc Srp Zář Říj Lis Pro},
      :order             => [:day, :month, :year]
    },

    # Time
    :time => {
      :formats => {
        :default => "%a %d. %B %Y %H:%M %z",
        :short   => "%d. %m. %H:%M",
        :long    => "%A %d. %B %Y %H:%M",
      },
      :am => 'am',
      :pm => 'pm'
    },

    # Numbers
    :number => {
      :format => {
        :precision => 3,
        :separator => '.',
        :delimiter => ',',
        :significant => false,
        :strip_insignificant_zeros => false
      },
      :currency => {
        :format => {
          :unit => 'Kč',
          :precision => 2,
          :format    => '%n %u',
          :separator => ",",
          :delimiter => " ",
          :significant => false,
          :strip_insignificant_zeros => false
        }
      },
      :human => {
        :format => {
          :precision => 1,
          :delimiter => '',
          :significant => false,
          :strip_insignificant_zeros => false
        },
       :storage_units => {
         :format => "%n %u",
         :units => {
           :byte => "B",
           :kb   => "KB",
           :mb   => "MB",
           :gb   => "GB",
           :tb   => "TB",
         }
       },
       :decimal_units => {
         :format => "%n %u",
         :units => {
           :unit => "",
           :thousand => "Tisíc",
           :million => "Milion",
           :billion => "Miliarda",
           :trillion => "Bilion",
           :quadrillion => "Kvadrilion"
         }
       }
      },
      :percentage => {
        :format => {
          :delimiter => ''
        }
      },
      :precision => {
        :format => {
          :delimiter => ''
        }
      }
    },

    # Distance of time ... helper
    # NOTE: In Czech language, these values are different for the past and for the future. Preference has been given to past here.
    :datetime => {
      :prompts => {
        :second => "Sekunda",
        :minute => "Minuta",
        :hour => "Hodina",
        :day => "Den",
        :month => "Měsíc",
        :year => "Rok"
      },
      :distance_in_words => {
        :half_a_minute => 'půl minutou',
        :less_than_x_seconds => {
          :one => 'asi před sekundou',
          :other => 'asi před %{count} sekundami'
        },
        :x_seconds => {
          :one => 'sekundou',
          :other => '%{count} sekundami'
        },
        :less_than_x_minutes => {
          :one => 'před necelou minutou',
          :other => 'před ani ne %{count} minutami'
        },
        :x_minutes => {
          :one => 'minutou',
          :other => '%{count} minutami'
        },
        :about_x_hours => {
          :one => 'asi hodinou',
          :other => 'asi %{count} hodinami'
        },
        :x_days => {
          :one => '24 hodinami',
          :other => '%{count} dny'
        },
        :about_x_months => {
          :one => 'asi měsícem',
          :other => 'asi %{count} měsíci'
        },
        :x_months => {
          :one => 'měsícem',
          :other => '%{count} měsíci'
        },
        :about_x_years => {
          :one => 'asi rokem',
          :other => 'asi %{count} roky'
        },
        :over_x_years => {
          :one => 'více než před rokem',
          :other => 'více než %{count} roky'
        },
        :almost_x_years => {
          :one => 'téměř před rokem',
          :other => 'téměř před %{count} roky'
        }
      }
    },

    :helpers => {
      :select => {
        :prompt => "Prosím vyberte si"
      },

      :submit => {
        :create => "Vytvořit %{model}",
        :update => "Aktualizovat %{model}",
        :submit => "Uložit %{model}"
      }
    },

    :errors => {
      :format => "%{attribute} %{message}",
      :messages => CzechLocaleI18n::ERROR_MESSAGES
    },

    # ActiveRecord validation messages
    :activerecord => {
      :errors => {
        :messages => {
          :taken               => "již databáze obsahuje",
          :record_invalid      => "Validace je neúspešná: %{errors}"
        }.merge(CzechLocaleI18n::ERROR_MESSAGES),
        :template => {
          :header   => {
            :one => "Při ukládání objektu %{model} došlo k chybám a nebylo jej možné uložit",
            :other => "Při ukládání objektu %{model} došlo ke %{count} chybám a nebylo možné jej uložit"
          },
          :body  => "Následující pole obsahují chybně vyplněné údaje:"
        },
        :full_messages => {
          :format => "%{attribute} %{message}"
        }
      }
    }
  }
}
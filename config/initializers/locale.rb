# Encoding: utf-8
#
#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
I18n.default_locale = DEFAULT_LANGUAGE
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
AVAILABLE_LANGUAGE_CODES.each do |c|
  if LANGUAGE_CODES_MAP.key?(c)
    I18n.fallbacks[c.to_sym] = LANGUAGE_CODES_MAP[c]
    I18n.fallbacks[c.to_sym].concat([c.to_sym, DEFAULT_LANGUAGE.to_sym, :en])
  else
    I18n.fallbacks[c.to_sym] = [c.to_sym, DEFAULT_LANGUAGE.to_sym, :en]
  end
end

# Languages that require to specify biological gender (sex)
# in order to inflect properly when using nouns with second
# person in past tense.
module I18n
  module Backend
    module Genderize

      # Languages that need and support inflection.
      SupportedLanguages  = [ :ar, :lt, :pl, :ru, :sr, :uk ]

      # Genders table helps to initialize grammatical gender
      # by looking at sociological gender entered by user.
      Genders = {
                  :feminine   => %w(  f fem female feminine k kobieta pani woman
                                      laska girl dziewczyna dziewucha chick lady mrs mrs.
                                      miss missus missis mistress ms panna panienka ﺳﻴﺪۃ
                                      dziewczynka żona zena sayyidah Пані Госпожа Г-жа ),

                  :masculine  => %w(  m mal male masculine man dude guy gentleman
                                      mr mister pan chłopak boy chłopiec koleś gość
                                      lasek gostek monsieur hr herr Пан mr. سيد سادة
                                      mężczyzna mąż chłopaczek facet sayyid Господин Г-н maleman ),
                }

        Genders.default = :neuter

    end
  end
end

# Grammatical gender aware translate.
module I18n
  module Backend
    module Genderize

      def translate(locale, key, options = {})
        g = options.delete(:gender)
        if not (g.nil? || key.is_a?(Enumerable))
          g = g.to_sym
          subkey = Genders[g.to_sym]
          key = "#{key}.#{subkey}".to_sym
        end
        super(locale, key, options)
      end

      # Initialize fast mapping table using data from Genders.
      def included(m)
        return if instance_variable_defined?(:@genders_guesser)
        @genders_guesser  = {}
        @known_genders    = []
        Genders.each_pair do |gname,gtable|
          @known_genders.push gname
          gtable.each do |word|
            @genders_guesser[word.to_sym] = gname
          end
        end
        @genders_guesser.default = Genders.default
        @known_genders.push Genders.default
        @known_genders.map! { |g| g.to_s }
        nil
      end
      module_function :included

      # Does language needs and supports inflection by gender?
      def supports?(l=nil)
        SupportedLanguages.include? l.nil? ? I18n.locale.to_sym : l.to_sym
      end
      module_function :supports?

      # Deduce grammatical gender using given gender and mapping.
      def guess(gender_description="")
        gender_description ||= ""
        @genders_guesser[gender_description.downcase.to_sym]
      end
      module_function :guess

      # Array of strings with known grammatical genders.
      def known_genders
        @known_genders
      end
      module_function :known_genders

    end
  end
end

I18n::Backend::Simple.send(:include, I18n::Backend::Genderize)

module LanguageHelper
  def available_language_options
    options = []
    AVAILABLE_LANGUAGES.each do |locale, language|
      options << [language, locale]
    end
    options.sort_by { |o| o[0] }
  end

  def options_for_gender_select
    grammatical_gender = current_user.grammatical_gender
    genders_list = I18n::Backend::Genderize.known_genders.map do |gender|
      [t(".#{gender}"), gender]
    end
    if grammatical_gender.blank?
      grammatical_gender = I18n::Backend::Genderize.guess(user.profile.gender)
    end
    options_for_select(genders_list, grammatical_gender.to_s)
  end

  def gender_select_disabled
    not I18n::Backend::Genderize.supports?(current_user.language)
  end

  def grammatical_gender_languages
    @glang_cache ||= array_or_string_for_javascript(I18n::Backend::Genderize::SupportedLanguages)
  end

  def options_for_grammatical_gender_block
    enabled = I18n::Backend::Genderize.supports? current_user.language
    {:style => 'display: ' + (enabled ? 'inline' : 'none') + ';' +
              ' margin-left: 1em; margin-right: 0.5em;'
    }
  end
end

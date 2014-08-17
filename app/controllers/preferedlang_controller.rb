class PreferedlangController < ApplicationController
  before_filter :authenticate_user!

  def create
      list_of_languages = params[:pref_languages]
      list_of_languages.each do |lang|
        lang = lang.to_i
        print lang
        language = Preferedlanguage.find(lang)
        current_user.preferedlanguages << language
      end
      redirect_to '/stream'
  end
end

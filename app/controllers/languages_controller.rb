class LanguagesController 

  def index
    if params[:q] && params[:q].length > 1
      params[:limit] = !params[:limit].blank? ? params[:limit].to_i : 10
      @languages = Language.autocomplete(params[:q]).limit(params[:limit] - 1)
      prep_languages_for_javascript
      respond_to do |format|
        format.json{ render(:json => @languages.to_json, :status => 200) }
      end
    else
      respond_to do |format|
        format.json{ render :nothing => true, :status => 422 }
        format.html{ redirect_to tag_path('partytimeexcellent') }
      end
    end
  end
  def language_has_capitals?
    mb_language = params[:name].mb_chars
    mb_language.downcase != mb_language
  end

  def downcased_language_name
    params[:name].mb_chars.downcase.to_s
  end

  def prep_languages_for_javascript
    @languages.map! do |language|
      { :name  => (language.name) }
    end

    @languages << { :name  => (params[:q]) }
    @languages.uniq!
  end
end

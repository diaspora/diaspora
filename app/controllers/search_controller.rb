class SearchController < ApplicationController


  def index
    
  end

  def query
    @term = params[:searchterm]
    #@posts = Post.connection.select_all("SELECT * FROM posts WHERE text LIKE '%#{@term}%'")
    # next line is okay
    #@posts = Post.find_by_sql("SELECT * FROM posts WHERE text LIKE '%#{@term}%'")
    @posts = Post.find_with_ferret(@term)

    @results = Array.new
    @posts.each do |post|
      result = Hash.new
      #result[:text]   = post.text
      index = post.text.index(@term)
      Rails.logger.debug "-----------index #{index}"
      if index < 50
        start = 0
      else
        start = index-50
      end

      Rails.logger.debug "-----------length #{post.text.length}"
      if index > post.text.length-50
        endind = post.text.length
      else
        endind = index+50
      end
      Rails.logger.debug "-----------s,e #{start} #{endind}"

      result[:context] = '...'+post.text[start,endind]+'...'
      Rails.logger.debug "-----------result    #{result}"

      @results.push(result)
    end
    #Rails.logger.debug "-----------posts #{@posts}"
    #Rails.logger.debug "-----------results #{results}"
  end


end

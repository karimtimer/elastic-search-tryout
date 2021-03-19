class SearchController < ApplicationController

  def search
    unless params[:query].blank?
      @results = Author.search( params[:query] )
    end
  end

end

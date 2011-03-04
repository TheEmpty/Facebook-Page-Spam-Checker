# TODO: check the indention. Had to switch IDEs.

require 'open-uri'

class SearchControllerController < ApplicationController
  def index
  end
  
  def show
	# TODO: SearchController.show
    @json = ActiveSupport::JSON.decode(open(nil).read)['data']
  end

  def search
    @search[:page]   = params[:page] || 1
	@search[:limit]  = 25
	@search[:offset] = (@search[:page]-1) * @search[:limit]
	
    # JSON.decode(open(url).read)['data']
    @json = ActiveSupport::JSON.decode(open("https://graph.facebook.com/search?q=#{params[:q]}&type=page&limit=#{@search[:limit]+1}&offset=#{@search[:offset]}").read)['data']
	# in the query above, we pull 26 results, however we are only going to show 25.
	# but if there is a 26th, then we know there is a next page.
	if @json.length == (@search[:limit] + 1)
	  @search[:more] = true
	  @json.pop # remove the last element
	else
	  @search[:more] = false
	end
	
    respond_to do |format|
      format.html 
      format.xml  { render :xml  => [@json,@search] }
      format.json { render :json => [@json,@search] }
    end
  end
end

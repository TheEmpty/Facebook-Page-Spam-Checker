require 'open-uri'
# TODO: fix the tabs again

class SearchController < ApplicationController
  def index
  end
  
  def show
    @page = ActiveSupport::JSON.decode(open("http://graph.facebook.com/#{params[:id]}").read)
    if @page['likes'] == nil
      render :text => 'You have entered an invald page ID. Please confirm the page ID and try again.', :layout => true and return
    end
	@page['linked_name'] = "<a href='#{@page['link']}' target='_blank' title='#{@page['name']}'>#{@page['name']}</a>"
    
    # TODO: save the data in database and load it only once a week - also then provide a link to show progress from week to week
    page = Page.find_or_create_by_page_id(params[:id])
    @averages = page.get_or_create_averages
	if @averages[:maxed]
	  flash[:notice] = 'There may be more data that was unavailable when compiling this data'
	end
    
    respond_to do |format|
      format.html
      format.js
    end
    
  end

  def search
    if not params[:page].nil?
      params[:page] = params[:page].to_i
      if 1 > params[:page]
        params[:page] = nil
      end
    end
    
    @search          = Hash.new
    @search[:page]   = params[:page]|| 1
	  @search[:limit]  = 25
	  @search[:offset] = (@search[:page]-1) * @search[:limit]
	
    query = URI.escape(params[:q], Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    # JSON.decode(open(url).read)['data']
    @json = ActiveSupport::JSON.decode(open("http://graph.facebook.com/search?q=#{query}&type=page&limit=#{@search[:limit]+1}&offset=#{@search[:offset]}").read)['data']
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
      format.js
      format.xml  { render :xml  => [@json,@search] }
      format.json { render :json => [@json,@search] }
    end
  end
end

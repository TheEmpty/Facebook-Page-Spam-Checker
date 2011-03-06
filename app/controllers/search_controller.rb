require 'open-uri'

class SearchController < ApplicationController
  def index
  end
  
  def show
    # TODO: save the data in database and load it only once a week - also then provide a link to show progress from week to week
    limit = 1000000
	  @json = ActiveSupport::JSON.decode(open("http://graph.facebook.com/#{params[:id]}/posts?limit=#{limit}").read)
	  @page = ActiveSupport::JSON.decode(open("http://graph.facebook.com/#{params[:id]}").read)
    @page['linked_name'] = "<a href='#{@page['link']}' target='_blank' title='#{@page['name']}'>#{@page['name']}</a>"
    
    @post_count = @json['data'].count
    # we +2 here because the pagination is included in the limit
    flash[:notice] = "This pages has posted over #{limit}, our report may not be accurate" if (@post_count+2) >= limit
    
    # likes and comments of all posts
    @post_likes    = 0
    @post_comments = 0
    first_post_time  = false
    @json['data'].each do |post|
      @post_likes += post['likes']['count'] if post['likes']
      @post_comments += post['comments']['count'] if post['comments']
      first_post_time  = post['created_time']
    end
    
    # average posts
    if first_post_time
      first_post_time = Time.parse(first_post_time)
      @days = Time.now - first_post_time
      @days = @days / (24 * 60 * 60)
      logger.debug "Days: #{@days}"
      @average_posts = @days / @post_count
    else
      @average_posts = false
    end
    logger.debug @average_posts
    
    # average likes
    if @post_count > 0 and @post_likes > 0
      @average_likes = @post_likes / @post_count
    else
      @average_likes = false
    end
    
    # average comments
    if @post_comments > 0
      @average_comments = @post_comments / @post_count
    end
    @average_interactions = @average_comments + @average_likes
    
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

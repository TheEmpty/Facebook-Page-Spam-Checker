# TODO: fix tabs
require 'open-uri'

class Page < ActiveRecord::Base
  has_many :results
  RESULTS_VERSION = 1.2
  
  def get_or_create_averages(time = 1.week.ago)
    last_result = self.results.where(['version = ?', Page::RESULTS_VERSION]).order('version, updated_at DESC').first
    if last_result and last_result.created_at >= time
	  averages = last_result.averages
	else
	  averages = generate_result
	  res = self.results.new
	  res.averages = averages
	  res.version = Page::RESULTS_VERSION
	  res.save
	  logger.warn res.errors if not res.errors.blank?
	end
	return averages
  end
  
  def generate_result
		limit = 1000 # due note that Facebook might say it is too much and return their max. Point is, we want as much as we can get.
		json = ActiveSupport::JSON.decode(open("http://graph.facebook.com/#{self[:page_id]}/posts?limit=#{limit}").read)
		
		# should have a max of 5 pages, then flash a notice. Facebook will only allow so many chained hits
		max_pages = 5 - 1 # starts at zero, not one.
		max_pages.times do |page|
		  if json['paging']['next']
			sec = ActiveSupport::JSON.decode(open(json['paging']['next']).read)
			break if sec['data'].blank?
			sec['data'].each do |key, value|
			  json['data'][key] = value
			end
			json['maxed'] = true if page == max_pages
			json['paging']['next'] = sec['paging']['next']
		  else
			break
		  end
		end
		
		generate_averages(json)
  end
  
  def generate_averages(json)
		averages = Hash.new
		averages[:post_count_total] = json['data'].count
		post_count  = json['data'].count.to_f # only convert it once to save proccesing power, used in division to provide more accurate numbers
		
		# likes and comments of all posts
		post_likes    = 0
		post_comments = 0
		first_post_time  = false
		json['data'].each do |post|
		  post_likes += post['likes']['count'] if post['likes']
		  post_comments += post['comments']['count'] if post['comments']
		  first_post_time  = post['created_time']
		end
		averages[:post_likes_total] = post_likes        # yeah it's not really an average but,
		averages[:post_comments_total] = post_comments  # it's data that is generated to calculate them and could be usefull
		
		# average posts
		if first_post_time
		  first_post_time = Time.parse(first_post_time)
		  days = Time.now - first_post_time
		  days = days / (24 * 60 * 60)
		  average_posts = post_count / days
		  averages[:based_on_days] = days
		  averages[:posts_per_day] = average_posts
		end
		
		# average likes
		if post_count > 0 and post_likes > 0
		  average_likes = post_likes / post_count
		  averages[:likes_per_post] = average_likes 
		end
		
		# average comments
		if post_comments > 0
		  average_comments = post_comments / post_count
		  averages[:comments_per_post] = average_comments
		end
		
		if average_comments or average_likes
		  average_interactions = 0
		  average_interactions += average_comments if average_comments
		  average_interactions += average_likes    if average_likes
		  averages[:interactions_per_post] = average_interactions
		end
		averages[:maxed] = (not json['maxed'].nil?)
		averages[:meta] = {:created_at => Time.now, :version => Page::RESULTS_VERSION}
		
		return averages
  end
  
end

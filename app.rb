#!/usr/bin/env ruby

require_relative './config/environment'
require_relative './models/tweet'


get '/styles/:file.css' do
  scss params[:file].to_sym
end

# OmniAuth routes
get '/auth/twitter/callback' do
  login_user(env)
  redirect to('/')
end
get '/auth/failure' do
  logout_user
  "failed =("
end

# Regular routes
get '/' do
  @tweets = Tweet.order("created_at DESC")
  @greets = "Hi there!"
  @greets = "Hi there #{current_user_nick}" if logged_in?

  # stub entry
  @tweets << Tweet.new
  @tweets[0].message = "my single tweet ever!"
  @tweets[0].user = "noj"

  haml :index
end

post '/tweet' do
  redirect to("/auth/twitter") if !logged_in?
  message = params[:message]
  if message.nil? || message.empty?
    redirect to("/invalid?message=#{message}")
  end

  tweet = Tweet.new
  tweet.user = current_user_nic
  tweet.uid = current_user_id
  tweet.message = trim_message(message)

  if tweet.save
    onetweet(tweet)
    redirect to("/")
  else
    redirect to("/?error")
  end
end

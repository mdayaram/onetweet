#!/usr/bin/env ruby

require_relative './config/environment'
require_relative './models/tweet'

before do
  @user_tweet = nil
  if logged_in?
    tweet = Tweet.where(uid: user_id).first
    @user_tweet = tweet.message if !tweet.nil?
  end
end


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
get '/logout' do
  logout_user
  redirect to("/")
end

# Regular routes
get '/' do
  @tweets = Tweet.order("created_at DESC")
  @greets = "Hi there!"
  @greets = "Hi there #{user_nick}" if logged_in?

  haml :index
end

post '/tweet' do
  raise "You need to login to tweet!" if !logged_in?
  raise "You've already tweeted!" if !@user_tweet.nil?

  message = params[:message]
  if message.nil? || message.empty?
    redirect to("/")
  end

  tweet = Tweet.new do |t|
    t.user = user_nick
    t.uid = user_id
    t.message = message
  end

  if tweet.save
    redirect to("/")
  else
    redirect to("/?error")
  end
end

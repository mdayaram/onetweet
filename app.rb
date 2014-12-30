#!/usr/bin/env ruby

require_relative './config/environment'
require_relative './models/tweet'

before do
  @tweets = Tweet.order("created_at DESC")
  @user_tweet = nil
  if logged_in?
    tweet = Tweet.where(uid: user_id).first
    @user_tweet = tweet.message if !tweet.nil?
    @user_nick = user_nick
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
  if @user_tweet.nil?
    haml :'index/new'
  else
    haml :'index/done'
  end
end

post '/tweet' do
  message = params[:message]
  if !logged_in?
    save_draft(message)
    return redirect to("/auth/twitter")
  elsif !@user_tweet.nil?
    return "You've already tweeted this phrase: #{@user_tweet}"
  end

  if message.nil? || message.empty?
    return redirect to("/")
  end

  tweet = Tweet.new do |t|
    t.user = user_nick
    t.uid = user_id
    t.message = message
  end

  begin
    tweet.save!
  rescue Exception => e
    return "Oh no! There was an error when tweeting!\n#{e.message}"
  end
  save_draft(nil)
  redirect to("/")
end

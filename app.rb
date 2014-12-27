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
  if !logged_in?
    haml :'index/new'
  elsif @user_tweet.nil?
    haml :'index/ready'
  else
    haml :'index/done'
  end
end

post '/tweet' do
  if !logged_in?
    return "You need to login in order to tweet!"
  elsif !@user_tweet.nil?
    return "You've already tweeted this phrase: #{@user_tweet}"
  end

  message = params[:message]
  if message.nil? || message.empty?
    redirect to("/")
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
  redirect to("/")
end

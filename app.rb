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

  tweet = Tweet.new
  tweet.user = user_nick
  tweet.uid = user_id
  tweet.message = trim_message(message)

  if tweet.save
    publish(tweet)
    redirect to("/")
  else
    redirect to("/?error")
  end
end

# Misc helper stuff.
def publish(tweet)
  raise "Need to be logged in to tweet!" if !logged_in?
  raise "You have already tweeted!" if !@user_tweet.nil?
  message = "#{tweet_header}#{trim_message(tweet.message)}#{tweet_footer}"
  settings.twitter.update(message) if !settings.twitter.nil?
end

def tweet_footer
  " - @#{user_nick}"
end
def tweet_header
  ""
end
def trim_message(msg)
  cap = 140 - tweet_footer.length - tweet_header.length - msg.length
  if cap < 0
    # remove the excess from the message, minus 3 for an added ellipse.
    msg = msg[0..(msg.length + cap - 1 - 3)] + "..."
  end
  msg
end

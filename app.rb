#!/usr/bin/env ruby

require_relative './config/environment'
require_relative './models/tweet'


get '/styles/:file.css' do
  scss params[:file].to_sym
end

# OmniAuth routes
get '/auth/twitter/callback' do
  session[:uid] = env['omniauth.auth']['uid']
  redirect to('/')
end
get '/auth/failure' do
  "failed =("
end

get '/' do
  @tweets = Tweet.order("created_at DESC")

  # stub entry
  @tweets << Tweet.new
  @tweets[0].message = "hi there"
  @tweets[0].user = "noj"

  haml :index
end


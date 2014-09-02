#!/usr/bin/env ruby

require_relative './config/environment'
require_relative './models/tweet'

get '/styles/:file.css' do
  scss params[:file].to_sym
end

get '/' do
  @tweets = Tweet.order("created_at DESC")
  @tweets << Tweet.new
  @tweets[0].message = "hi there"
  @tweets[0].user = "noj"
  haml :index
end


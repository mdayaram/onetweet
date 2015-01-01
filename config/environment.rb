require 'rubygems'
require 'bundler'
Bundler.setup
require 'sinatra'
require 'active_record'
require 'sinatra/activerecord'
require 'haml'
require 'sass'
require 'omniauth-twitter'
require 'twitter'
require_relative '../models/tweet'

configure do
  set :server, 'webrick' # needed because sinatra thinks the twitter gem is a server.
  set :app_file, File.expand_path(File.join(File.dirname(__FILE__), "..", "app.rb"))
  set :haml, { :format => :html5 }
  use Rack::Session::Cookie # required by omniauth
end

configure :development do
  set :database, 'sqlite:///db/dev.sqlite3'
  set :show_exceptions, true
  set :user_ct, Tweet.count

  # configure fake /auth/twitter route for dev purposes
  get '/auth/twitter' do
    uid = settings.user_ct
    unick = "user_#{settings.user_ct}"
    env['omniauth.auth'] = { 'uid' => uid , 'info' => { 'nickname' => unick } }
    settings.user_ct += 1
    status, headers, body = call env.merge("PATH_INFO" => '/auth/twitter/callback')
    [status, headers, body.map(&:upcase)]
  end
end

configure :production do
  # configures get '/auth/twitter' route automatically
  use OmniAuth::Builder do
    provider :twitter, ENV["AUTH_CONSUMER_KEY"], ENV["AUTH_CONSUMER_SECRET"],
      { :authorize_params => { :force_login => 'true' } }
  end

  db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

  ActiveRecord::Base.establish_connection(
    :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
    :host     => db.host,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8'
  )

  twitter_client = Twitter::REST::Client.new do |config|
    config.consumer_key = ENV["ONETWEET_CONSUMER_KEY"]
    config.consumer_secret = ENV["ONETWEET_CONSUMER_SECRET"]
    config.access_token = ENV["ONETWEET_ACCESS_TOKEN"]
    config.access_token_secret = ENV["ONETWEET_ACCESS_SECRET"]
  end
  Tweet.client = twitter_client
end

helpers do
  def login_user(env)
    session[:uid] = env['omniauth.auth']['uid']
    session[:nick] = env['omniauth.auth']['info']['nickname']
  end
  def logout_user
    session[:uid] = nil
    session[:nick] = nil
    session[:draft] = nil
  end
  def logged_in?
    !session[:uid].nil?
  end
  def user_id
    session[:uid]
  end
  def user_nick
    session[:nick]
  end
  def user_draft
    session[:draft]
  end
  def save_draft(message)
    session[:draft] = message
  end

end

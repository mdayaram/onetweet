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

configure do
  set :server, 'webrick' # needed because sinatra thinks the twitter gem is a server.
  set :app_file, File.expand_path(File.join(File.dirname(__FILE__), "..", "app.rb"))
  set :haml, { :format => :html5 }

  use OmniAuth::Builder do
    provider :twitter, ENV["AUTH_CONSUMER_KEY"], ENV["AUTH_CONSUMER_SECRET"],
      {
      :authorize_params => { :force_login => 'true' }
    }
  end
end

configure :development do
  set :database, 'sqlite:///db/dev.sqlite3'
  set :show_exceptions, true
  set :twitter, nil
end

configure :production do
  db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

  ActiveRecord::Base.establish_connection(
    :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
    :host     => db.host,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8'
  )

  onetweet_client = Twitter::REST::Client.new do |config|
    config.consumer_key = ENV["ONETWEET_CONSUMER_KEY"]
    config.consumer_secret = ENV["ONETWEET_CONSUMER_SECRET"]
    config.access_token = ENV["ONETWEET_ACCESS_TOKEN"]
    config.access_token_secret = ENV["ONETWEET_ACCESS_SECRET"]
  end
  set :onetweet, onetweet_client
end

helpers do
  def login_user(env)
    session[:uid] = env['omniauth.auth']['uid']
    session[:nick] = env['omniauth.auth']['info']['nickname']
  end
  def logout_user
    session[:uid] = nil
    session[:nick] = nil
  end
  def current_user_id
    session[:uid]
  end
  def current_user_nick
    session[:nick]
  end
  def logged_in?
    !session[:uid].nil?
  end

  def tweet_footer
    "\" - #{current_user_nick}"
  end
  def tweet_header
    "\""
  end

  def onetweet(msg)
    raise "Need to be logged in to tweet!" if !logged_in?
    cap = 140 - tweet_footer.length - tweet_header.length - msg.length
    if cap < 0
      # remove the excess from the message, minus 3 for an added ellipse.
      msg = msg[0..(msg.length + cap - 1 - 3)] + "..."
    end
    message = "#{tweet_header}#{msg}#{tweet_footer}"
    settings.onetweet.update(message) if !settings.onetweet.nil?
  end
end

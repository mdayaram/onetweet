require 'sinatra/activerecord'

class Tweet < ActiveRecord::Base
  @@client = nil # initialized in environment.

  def self.client=(client)
    @@client = client
  end

  def after_save

  end
end


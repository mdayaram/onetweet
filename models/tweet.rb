require 'sinatra/activerecord'

class Tweet < ActiveRecord::Base
  @@client = nil # initialized in environment.

  validates :uid, uniqueness: true
  validates :message, presence: true

  before_save :trim_message
  after_save :publish

  def self.client=(client)
    @@client = client
  end

  private

  def publish
    msg = "#{tweet_header}#{self.message}#{tweet_footer}"
    raise "Message longer than 140 characters! (#{msg.length})" if msg.length > 140
    @@client.update(msg) if !@@client.nil?
    puts "TWEET: #{msg}"
  end

  def tweet_footer
    " - @#{user}"
  end

  def tweet_header
    ""
  end

  def trim_message
    cap = 140 - tweet_footer.length - tweet_header.length - self.message.length
    if cap < 0
      # remove the excess from the message, minus 3 for an added ellipse.
      tmp = self.message.dup
      self.message = tmp[0..(tmp.length + cap - 1 - 3)] + "..."
    end
    true
  end
end


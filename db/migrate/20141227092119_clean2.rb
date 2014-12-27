class Clean2 < ActiveRecord::Migration
  def up
    Tweet.delete_all
  end

  def down
  end
end

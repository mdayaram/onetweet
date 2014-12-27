class AddTweetUidUniqueIndex < ActiveRecord::Migration
  def up
    add_index :tweets, :uid, unique: true
  end

  def down
    remove_index :tweets, column: :uid
  end
end

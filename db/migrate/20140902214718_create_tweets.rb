class CreateTweets < ActiveRecord::Migration
  def up
    create_table :tweets do |t|
      t.string :user
      t.string :message
      t.timestamps
    end
  end

  def down
    drop_table :tweets
  end
end

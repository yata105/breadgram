class CreateFollows < ActiveRecord::Migration[8.0]
  def change
    create_table :follows do |t|
      t.integer :follower_id
      t.integer :followed_id
      t.timestamps

      t.index [:follower_id, :followed_id], unique: true
    end
  end
end

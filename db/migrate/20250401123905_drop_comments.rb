class DropComments < ActiveRecord::Migration[8.0]
  def up
    drop_table :comments
  end
end

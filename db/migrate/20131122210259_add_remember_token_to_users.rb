class AddRememberTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :remember_token, :string
    # Adding index on remember_token column because we will look up user by it
    add_index :users, :remember_token
  end
end

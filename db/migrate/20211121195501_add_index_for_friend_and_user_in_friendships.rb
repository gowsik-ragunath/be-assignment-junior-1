class AddIndexForFriendAndUserInFriendships < ActiveRecord::Migration[6.1]
  def change
    add_index :friendships, [ :friend_id, :user_id ], :unique => true, :name => 'by_friend_and_user'
  end
end

class Friendship < ApplicationRecord
  belongs_to :user, foreign_key: :user_id, class_name: "User"
  belongs_to :friend, foreign_key: :friend_id, class_name: "User"

  validates_uniqueness_of :friend_id, scope: :user_id

  after_create_commit :create_dependent_friend

  private

    def create_dependent_friend
      unless Friendship.exists?(user_id: self.friend_id, friend_id: self.user_id)
        Friendship.create(user_id: self.friend_id, friend_id: self.user_id)
      end
    end
end

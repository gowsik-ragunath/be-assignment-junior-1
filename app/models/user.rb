class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :expenses
  has_many :user_expenses, dependent: :destroy
  has_many :shared_expenses, through: :user_expenses
  has_many :friendships, class_name: "Friendship", foreign_key: :friend_id, dependent: :destroy
  has_many :friends, through: :friendships, source: :user
end

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :expenses
  has_many :paid_expenses, foreign_key: :payer_id, class_name: "Expense"
  has_many :user_expenses, dependent: :destroy
  has_many :shared_expenses, through: :user_expenses, source: "expense"
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  
  
  # Methods

  def total_balance
    (self.lent_amount - self.owed_amount).to_f
  end
end

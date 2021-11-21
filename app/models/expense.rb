class Expense < ApplicationRecord
  
  # Associations

  belongs_to :user
  has_many :user_expenses, dependent: :destroy
  has_many :users, through: :user_expenses

  # Rich text
  has_rich_text :description

  # Nested Atributes
  accepts_nested_attributes_for :user_expenses, allow_destroy: true

end

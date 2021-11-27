class Expense < ApplicationRecord

  # Attribute Accessor
  
  attr_accessor :split
  attr_accessor :equal_split_amount
  attr_accessor :user_expense_user_ids
  
  # Associations
  
  belongs_to :user
  belongs_to :payer, class_name: "User", foreign_key: :payer_id
  has_many :user_expenses, dependent: :destroy
  has_many :users, through: :user_expenses

  # Rich text
  
  has_rich_text :description

  # Validation callback

  before_validation :set_user_expense_user_ids

  # Validations
  
  validates :amount, presence: true, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: { greater_than: 0, less_than: 1000000 }
  validate :reject_repeating_user_expenses
  validate :owed_amount_sums_up, if: :unequal_split?
  validate :split_expense_must_have_payer

  # Nested Atributes
  
  accepts_nested_attributes_for :user_expenses, allow_destroy: true

  # Callbacks

  before_create :get_equal_split_amount, if: :equal_split?
  after_create_commit :update_paid_user_amount, if: :payer_expense_not_present?

  # scopes

  scope :paid_expenses, -> (user_id) { where(payer_id: user_id) }
  scope :borrowed_expenses, -> (user_id) { where.not(payer_id: user_id) }

  
  # Boolean method

  def equal_split?
    self.split.present? && self.split == "1" && self.amount.present?
  end

  def unequal_split?
    !equal_split?
  end

  def payer_expense_not_present?
    !self.user_expenses.pluck(:user_id).include?(self.payer_id)
  end

  private

    # Validation callback methods
    def set_user_expense_user_ids
      self.user_expense_user_ids = self.user_expenses.collect(&:user_id)
    end

    # Validation methods

    def reject_repeating_user_expenses
      user_expense_visited = []

      self.user_expenses.each do |user_expense|
        if user_expense_visited.include?(user_expense.user_id)
          errors.add(:user_expense, "User has been added more than once in the expense")
        else
          user_expense_visited << user_expense.user_id

          false
        end
      end
    end

    def owed_amount_sums_up
      owed_amount_sum = self.user_expenses.collect(&:owed_amount).compact.sum.to_f
      paid_amount_sum = self.user_expenses.collect(&:paid_amount).compact.sum.to_f
      
      if paid_amount_sum != self.amount
        # paid amount is not equal to the expense amount
        # E.g., Expense amount - 100
        # owed_amount - 100
        # paid_amount - 40 
        errors.add(:amount, "The total of everyone's paid shares ($#{paid_amount_sum}) is different than the total cost ($#{self.amount})")
      elsif owed_amount_sum != self.amount
        # owed amount is not equal to the expense amount
        # E.g., Expense amount - 100
        # owed_amount - 40
        # paid_amount - 100 
        errors.add(:amount, "The total of everyone's owed shares ($#{owed_amount_sum}) is different than the total cost ($#{self.amount})")
      end 
    end

    def split_expense_must_have_payer
      if equal_split? && !self.user_expense_user_ids.include?(self.payer_id)
        errors.add(:payer, "Expense amount is not split with payer")
      end
    end

    # User Expense methods

    def get_equal_split_amount
      user_expenses_count = self.user_expenses.size
      actual_amount = self.amount.to_f
      split_amount_arr = []


      user_expenses_count.times do
        equal_split = ("%.2f" % (actual_amount / user_expenses_count.to_f)).to_f
        actual_amount -= equal_split
        
        split_amount_arr << equal_split

        user_expenses_count -= 1
      end

      self.equal_split_amount = split_amount_arr.sort
    end

    # Callback methods

    def update_paid_user_amount
      owed_paid_amount_sum = self.user_expenses.pluck(:owed_amount, :paid_amount).flatten.sum

      self.user.lent_amount += owed_paid_amount_sum
      self.user.save
    end
end

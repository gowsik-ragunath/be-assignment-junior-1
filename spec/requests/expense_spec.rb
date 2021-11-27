require "rails_helper"

RSpec.describe "Expense", type: :request, g112721: true do

  before(:each) do
    @user = Fabricate(:user)

    @user_2 = Fabricate(:user)
    @user_3 = Fabricate(:user)
    @user_4 = Fabricate(:user)

    sign_in @user
  end

  describe "POST #create" do
    let(:without_split_valid_params) { 
      { 
        expense: { 
          date: Time.now, 
          description: "test",
          amount: 10,
          payer_id: @user.id,
          user_expenses_attributes: { 
            "0": { user_id: @user.id, paid_amount: 10 },
            "1": { user_id: @user_2.id, owed_amount: 10 }
          }
        } 
      } 
    }

    let(:with_split_valid_params) { 
      { 
        expense: { 
          date: Time.now, 
          description: "test",
          amount: 10,
          payer_id: @user.id,
          split: "1",
          user_expenses_attributes: {
            "0": { user_id: @user.id, paid_amount: 10 },
            "1": { user_id: @user_2.id, owed_amount: 10 }
          }
        }
      }
    }

    context "Valid split expense" do
      it "A user can create an Expense with amount that has only than 2 digits in decimal position", g112721ga: true do
        with_split_valid_params[:expense].update({ amount: 12.32 })
        post expenses_path, params: with_split_valid_params, xhr: true
        
        # Check request response
        expect(response).to have_http_status(200)
        expect(response.body).to include(root_url)

        # Reload exisiting records
        @user.reload
        @user_2.reload

        # Check expense record
        expense = Expense.order(:id).last

        expect(expense.payer_id).to eq(@user.id)
        expect(expense.amount).to eq(12.32)
        expect(expense.description.body.to_plain_text).to include("test")
        
        # Check user expense records
        user_expense = expense.user_expenses.find_by(user_id: @user.id)
        user_2_expense = expense.user_expenses.find_by(user_id: @user_2.id)

        # Amount will be equally split and owed_amount and paid_amount params will be ignored
        expect(user_expense.owed_amount).to eq(0)
        expect(user_expense.paid_amount).to eq(6.16)
        expect(user_2_expense.owed_amount).to eq(6.16)
        expect(user_2_expense.paid_amount).to eq(0)
        

        # Check overall user lent and owed amount
        expect(@user.lent_amount).to eq(6.16)
        expect(@user.owed_amount).to eq(0)
        expect(@user_2.lent_amount).to eq(0)
        expect(@user_2.owed_amount).to eq(6.16)
      end

      it "A user can create an Expense and it will be share with another user, passed paid_amount and owed_amount params will be skipped", g112721aa: true do
        post expenses_path, params: with_split_valid_params.merge, xhr: true
        
        # Check request response
        expect(response).to have_http_status(200)
        expect(response.body).to include(root_url)

        # Reload exisiting records
        @user.reload
        @user_2.reload

        # Check expense record
        expense = Expense.order(:id).last

        expect(expense.payer_id).to eq(@user.id)
        expect(expense.amount).to eq(10)
        expect(expense.description.body.to_plain_text).to include("test")
        
        # Check user expense records
        user_expense = expense.user_expenses.find_by(user_id: @user.id)
        user_2_expense = expense.user_expenses.find_by(user_id: @user_2.id)

        # Amount will be equally split and owed_amount and paid_amount params will be ignored
        expect(user_expense.owed_amount).to eq(0)
        expect(user_expense.paid_amount).to eq(5)
        expect(user_2_expense.owed_amount).to eq(5)
        expect(user_2_expense.paid_amount).to eq(0)
        

        # Check overall user lent and owed amount
        expect(@user.lent_amount).to eq(5)
        expect(@user.owed_amount).to eq(0)
        expect(@user_2.lent_amount).to eq(0)
        expect(@user_2.owed_amount).to eq(5)
      end

      it "A user can create an Expense without any other users", g112721a: true do
        with_split_valid_params[:expense][:user_expenses_attributes].delete(:"1")
        post expenses_path, params: with_split_valid_params.merge, xhr: true
        
        # Check request response
        expect(response).to have_http_status(200)
        expect(response.body).to include(root_url)

        # Reload exisiting records
        @user.reload

        # Check expense record
        expense = Expense.order(:id).last

        expect(expense.payer_id).to eq(@user.id)
        expect(expense.amount).to eq(10)
        expect(expense.description.body.to_plain_text).to include("test")
        
        # Check user expense records
        user_expense = expense.user_expenses.find_by(user_id: @user.id)

        # Amount will be equally split and owed_amount and paid_amount params will be ignored
        expect(user_expense.owed_amount).to eq(0)
        expect(user_expense.paid_amount).to eq(10)        

        # Check overall user lent and owed amount
        expect(@user.lent_amount).to eq(0)
        expect(@user.owed_amount).to eq(0)
      end


      it "A user can create an Expense without any other users, passed paid_amount and owed_amount params will be skipped", g112721a: true do
        post expenses_path, params: with_split_valid_params.merge, xhr: true
        
        # Check request response
        expect(response).to have_http_status(200)
        expect(response.body).to include(root_url)

        # Reload exisiting records
        @user.reload
        @user_2.reload

        # Check expense record
        expense = Expense.order(:id).last

        expect(expense.payer_id).to eq(@user.id)
        expect(expense.amount).to eq(10)
        expect(expense.description.body.to_plain_text).to include("test")
        
        # Check user expense records
        user_expense = expense.user_expenses.find_by(user_id: @user.id)
        user_2_expense = expense.user_expenses.find_by(user_id: @user_2.id)

        # Amount will be equally split and owed_amount and paid_amount params will be ignored
        expect(user_expense.owed_amount).to eq(0)
        expect(user_expense.paid_amount).to eq(5)
        expect(user_2_expense.owed_amount).to eq(5)
        expect(user_2_expense.paid_amount).to eq(0)
        

        # Check overall user lent and owed amount
        expect(@user.lent_amount).to eq(5)
        expect(@user.owed_amount).to eq(0)
        expect(@user_2.lent_amount).to eq(0)
        expect(@user_2.owed_amount).to eq(5)
      end

      it "A user can create an Expense and will share $100 expense with 2 other users", g112721b: true do
        # Add payer user expense
        user_3_expense = { "2": { user_id: @user_3.id, paid_amount: 10 } }
        with_split_valid_params[:expense][:user_expenses_attributes].update(user_3_expense)
        with_split_valid_params[:expense].update({ amount: 100 })
      
        post expenses_path, params: with_split_valid_params.merge, xhr: true
        
        # Check request response
        expect(response).to have_http_status(200)
        expect(response.body).to include(root_url)

        # Reload exisiting records
        @user.reload
        @user_2.reload
        @user_3.reload

        # Check expense record
        expense = Expense.order(:id).last

        expect(expense.payer_id).to eq(@user.id)
        expect(expense.amount).to eq(100)
        expect(expense.description.body.to_plain_text).to include("test")
        
        # Check user expense records
        user_expense = expense.user_expenses.find_by(user_id: @user.id)
        user_2_expense = expense.user_expenses.find_by(user_id: @user_2.id)
        user_3_expense = expense.user_expenses.find_by(user_id: @user_3.id)

        expect(user_expense.owed_amount).to eq(0)
        expect(user_expense.paid_amount).to eq(33.34)
        expect(user_2_expense.owed_amount).to eq(33.33)
        expect(user_2_expense.paid_amount).to eq(0)
        expect(user_3_expense.owed_amount).to eq(33.33)
        expect(user_3_expense.paid_amount).to eq(0)

        # Check overall user lent and owed amount
        expect(@user.lent_amount).to eq(66.66)
        expect(@user.owed_amount).to eq(0)
        expect(@user_2.lent_amount).to eq(0)
        expect(@user_2.owed_amount).to eq(33.33)
        expect(@user_3.lent_amount).to eq(0)
        expect(@user_3.owed_amount).to eq(33.33)
      end

      it "A user can create Expense with decimal value as amount and will be shared among 4 users", g112721c: true do
        # Add payer user expense
        user_3_expense = { "2": { user_id: @user_3.id, paid_amount: 60 } }
        user_4_expense = { "3": { user_id: @user_4.id, owed_amount: 30 } }
        with_split_valid_params[:expense][:user_expenses_attributes].update(user_3_expense)
        with_split_valid_params[:expense][:user_expenses_attributes].update(user_4_expense)
        with_split_valid_params[:expense].update({ amount: 33.5 })
      
        post expenses_path, params: with_split_valid_params, xhr: true
        
        # Check request response
        expect(response).to have_http_status(200)
        expect(response.body).to include(root_url)

        # Reload exisiting records
        @user.reload
        @user_2.reload
        @user_3.reload
        @user_4.reload

        # Check expense record
        expense = Expense.order(:id).last

        expect(expense.payer_id).to eq(@user.id)
        expect(expense.amount).to eq(33.5)
        expect(expense.description.body.to_plain_text).to include("test")
        
        # Check user expense records
        user_expense = expense.user_expenses.find_by(user_id: @user.id)
        user_2_expense = expense.user_expenses.find_by(user_id: @user_2.id)
        user_3_expense = expense.user_expenses.find_by(user_id: @user_3.id)
        user_4_expense = expense.user_expenses.find_by(user_id: @user_4.id)

        # User 1, 2 will have highest value
        expect(user_expense.owed_amount.to_f).to eq(0)
        expect(user_expense.paid_amount.to_f).to eq(8.38)
        expect(user_2_expense.owed_amount.to_f).to eq(8.38)
        expect(user_2_expense.paid_amount.to_f).to eq(0)
        expect(user_3_expense.owed_amount.to_f).to eq(8.37)
        expect(user_3_expense.paid_amount.to_f).to eq(0)
        expect(user_4_expense.owed_amount.to_f).to eq(8.37)
        expect(user_4_expense.paid_amount.to_f).to eq(0)

        # Check overall user lent and owed amount
        expect(@user.lent_amount.to_f).to eq(("%.2f" % (expense.amount - 8.38).to_f).to_f)
        expect(@user.owed_amount.to_f).to eq(0)
        expect(@user_2.lent_amount.to_f).to eq(0)
        expect(@user_2.owed_amount.to_f).to eq(8.38)
        expect(@user_3.lent_amount.to_f).to eq(0)
        expect(@user_3.owed_amount.to_f).to eq(8.37)
        expect(@user_4.lent_amount.to_f).to eq(0)
        expect(@user_4.owed_amount.to_f).to eq(8.37)
      end
    end

    context "Valid non split expense" do
      it "A user can create an Expense for themself by have expense amount value in both owed_amount and paid_amount", g112721k: true do
        # Add payer user expense
        user_expense = { "0": { user_id: @user.id, owed_amount: 100, paid_amount: 100 } }
        without_split_valid_params[:expense][:user_expenses_attributes].delete(:"1")
        
        without_split_valid_params[:expense][:user_expenses_attributes].update(user_expense)
        without_split_valid_params[:expense].update({ amount: 100, split: "0" })
      
        post expenses_path, params: without_split_valid_params, xhr: true
        
        # Check request response
        expect(response).to have_http_status(200)
        expect(response.body).to include(root_url)

        # Reload exisiting records
        @user.reload

        # Check expense record
        expense = Expense.order(:id).last

        expect(expense.payer_id).to eq(@user.id)
        expect(expense.amount).to eq(100)
        expect(expense.description.body.to_plain_text).to include("test")
        
        # Check user expense records
        user_expense = expense.user_expenses.find_by(user_id: @user.id)

        expect(user_expense.owed_amount).to eq(100)
        expect(user_expense.paid_amount).to eq(100)

        # Check overall user lent and owed amount
        expect(@user.lent_amount).to eq(0)
        expect(@user.owed_amount).to eq(0)
      end

      it "A user can create an Expense and will pay the complete expense of another user", g112721d: true do
        post expenses_path, params: without_split_valid_params, xhr: true
        
        # Check request response
        expect(response).to have_http_status(200)
        expect(response.body).to include(root_url)

        # Reload exisiting records
        @user.reload
        @user_2.reload

        # Check expense record
        expense = Expense.order(:id).last

        expect(expense.payer_id).to eq(@user.id)
        expect(expense.amount).to eq(10)
        expect(expense.description.body.to_plain_text).to include("test")
        
        # Check user expense records
        user_expense = expense.user_expenses.find_by(user_id: @user.id)
        user_2_expense = expense.user_expenses.find_by(user_id: @user_2.id)

        expect(user_expense.owed_amount).to eq(0)
        expect(user_expense.paid_amount).to eq(10)
        expect(user_2_expense.owed_amount).to eq(10)
        expect(user_2_expense.paid_amount).to eq(0)
        

        # Check overall user lent and owed amount
        expect(@user.lent_amount).to eq(10)
        expect(@user.owed_amount).to eq(0)
        expect(@user_2.lent_amount).to eq(0)
        expect(@user_2.owed_amount).to eq(10)
      end

      it "A user can create an paid $100 Expense with 3 other users and current user and 1 other user will pay and 2 users will still have owed amount", g112721f: true do
        # Add payer user expense
        user_expense = { "0": { user_id: @user.id, paid_amount: 40 } }
        user_2_expense = { "1": { user_id: @user_2.id, owed_amount: 10 } }
        user_3_expense = { "2": { user_id: @user_3.id, paid_amount: 60 } }
        user_4_expense = { "3": { user_id: @user_4.id, owed_amount: 90 } }
        
        without_split_valid_params[:expense][:user_expenses_attributes].update(user_expense)
        without_split_valid_params[:expense][:user_expenses_attributes].update(user_2_expense)
        without_split_valid_params[:expense][:user_expenses_attributes].update(user_3_expense)
        without_split_valid_params[:expense][:user_expenses_attributes].update(user_4_expense)
        without_split_valid_params[:expense].update({ amount: 100, split: "0" })
      
        post expenses_path, params: without_split_valid_params, xhr: true
        
        # Check request response
        expect(response).to have_http_status(200)
        expect(response.body).to include(root_url)

        # Reload exisiting records
        @user.reload
        @user_2.reload
        @user_3.reload
        @user_4.reload

        # Check expense record
        expense = Expense.order(:id).last

        expect(expense.payer_id).to eq(@user.id)
        expect(expense.amount).to eq(100)
        expect(expense.description.body.to_plain_text).to include("test")
        
        # Check user expense records
        user_expense = expense.user_expenses.find_by(user_id: @user.id)
        user_2_expense = expense.user_expenses.find_by(user_id: @user_2.id)
        user_3_expense = expense.user_expenses.find_by(user_id: @user_3.id)
        user_4_expense = expense.user_expenses.find_by(user_id: @user_4.id)
        
        expect(user_expense.owed_amount).to eq(0)
        expect(user_expense.paid_amount).to eq(40)
        expect(user_2_expense.owed_amount).to eq(10)
        expect(user_2_expense.paid_amount).to eq(0)
        expect(user_3_expense.owed_amount).to eq(0)
        expect(user_3_expense.paid_amount).to eq(60)
        expect(user_4_expense.owed_amount).to eq(90)
        expect(user_4_expense.paid_amount).to eq(0)

        # Check overall user lent and owed amount
        expect(@user.lent_amount).to eq(40)
        expect(@user.owed_amount).to eq(0)
        expect(@user_2.lent_amount).to eq(0)
        expect(@user_2.owed_amount).to eq(10)
        expect(@user_3.lent_amount).to eq(60)
        expect(@user_3.owed_amount).to eq(0)
        expect(@user_4.lent_amount).to eq(0)
        expect(@user_4.owed_amount).to eq(90)
      end

      it "A user can create Expense with decimal value as amount and will be shared unequally", g112721f: true do
        # Add payer user expense
        user_expense = { "0": { user_id: @user.id, paid_amount: 34.44 } }
        user_2_expense = { "1": { user_id: @user_2.id, owed_amount: 11.30 } }
        user_3_expense = { "2": { user_id: @user_3.id, paid_amount: 65.66 } }
        user_4_expense = { "3": { user_id: @user_4.id, owed_amount: 88.80 } }
        
        without_split_valid_params[:expense][:user_expenses_attributes].update(user_expense)
        without_split_valid_params[:expense][:user_expenses_attributes].update(user_2_expense)
        without_split_valid_params[:expense][:user_expenses_attributes].update(user_3_expense)
        without_split_valid_params[:expense][:user_expenses_attributes].update(user_4_expense)
        without_split_valid_params[:expense].update({ amount: 100.1, split: "0" })
      
        post expenses_path, params: without_split_valid_params, xhr: true
        
        # Check request response
        expect(response).to have_http_status(200)
        expect(response.body).to include(root_url)

        # Reload exisiting records
        @user.reload
        @user_2.reload
        @user_3.reload
        @user_4.reload

        # Check expense record
        expense = Expense.order(:id).last

        expect(expense.payer_id).to eq(@user.id)
        expect(expense.amount).to eq(100.1)
        expect(expense.description.body.to_plain_text).to include("test")
        
        # Check user expense records
        user_expense = expense.user_expenses.find_by(user_id: @user.id)
        user_2_expense = expense.user_expenses.find_by(user_id: @user_2.id)
        user_3_expense = expense.user_expenses.find_by(user_id: @user_3.id)
        user_4_expense = expense.user_expenses.find_by(user_id: @user_4.id)

        # User 1, 2 will have highest value
        expect(user_expense.owed_amount.to_f).to eq(0)
        expect(user_expense.paid_amount.to_f).to eq(34.44)
        expect(user_2_expense.owed_amount.to_f).to eq(11.3)
        expect(user_2_expense.paid_amount.to_f).to eq(0)
        expect(user_3_expense.owed_amount.to_f).to eq(0)
        expect(user_3_expense.paid_amount.to_f).to eq(65.66)
        expect(user_4_expense.owed_amount.to_f).to eq(88.8)
        expect(user_4_expense.paid_amount.to_f).to eq(0)

        # Check overall user lent and owed amount
        expect(@user.lent_amount.to_f).to eq(34.44)
        expect(@user.owed_amount.to_f).to eq(0)
        expect(@user_2.lent_amount.to_f).to eq(0)
        expect(@user_2.owed_amount.to_f).to eq(11.3)
        expect(@user_3.lent_amount.to_f).to eq(65.66)
        expect(@user_3.owed_amount.to_f).to eq(0)
        expect(@user_4.lent_amount.to_f).to eq(0)
        expect(@user_4.owed_amount.to_f).to eq(88.8)
      end
    end

    context "InValid non split expense" do
      it "A user cannot create an Expense and pay the complete expense of another user without payer", g112721g: true do
        without_split_valid_params[:expense][:user_expenses_attributes].delete(:"0")
        post expenses_path, params: without_split_valid_params, xhr: true
        
        # Check request response
        expect(response).to have_http_status(200)
        expect(response.body).to include("paid shares (\\$0.0) is different than the total cost (\\$10.0)")

        # Check expense record
        expense = Expense.order(:id).last

        expect(expense).to be_nil
      end

      it "A user cannot create an Expense with other users when paid user have owed amount in the expense", g112721h: true do
        # Add payer user expense
        user_expense = { "0": { user_id: @user.id, owed_amount: 40 } }
        user_2_expense = { "1": { user_id: @user_2.id, owed_amount: 10 } }
        user_3_expense = { "2": { user_id: @user_3.id, paid_amount: 100 } }
        user_4_expense = { "3": { user_id: @user_4.id, owed_amount: 50 } }
        
        without_split_valid_params[:expense][:user_expenses_attributes].update(user_expense)
        without_split_valid_params[:expense][:user_expenses_attributes].update(user_2_expense)
        without_split_valid_params[:expense][:user_expenses_attributes].update(user_3_expense)
        without_split_valid_params[:expense][:user_expenses_attributes].update(user_4_expense)
        without_split_valid_params[:expense].update({ amount: 100, split: "0" })
      
        post expenses_path, params: without_split_valid_params, xhr: true
        
        # Check request response
        expect(response).to have_http_status(200)
        expect(response.body).to include("Payer can&#39;t owe any amount")

        # Check expense record
        expense = Expense.order(:id).last

        expect(expense).to be_nil
      end

      it "A user cannot create an Expense without any other user and value only in owed_amount", g112721i: true do
        # Add payer user expense
        user_expense = { "0": { user_id: @user.id, owed_amount: 100, paid_amount: 0 } }
        without_split_valid_params[:expense][:user_expenses_attributes].delete(:"1")
        
        without_split_valid_params[:expense][:user_expenses_attributes].update(user_expense)
        without_split_valid_params[:expense].update({ amount: 100, split: "0" })
      
        post expenses_path, params: without_split_valid_params, xhr: true
        
        # Check request response
        expect(response).to have_http_status(200)
        expect(response.body).to include("paid shares (\\$0.0) is different than the total cost (\\$100.0)")

        # Check expense record
        expense = Expense.order(:id).last

        expect(expense).to be_nil
      end

      it "A user cannot create an Expense without any other user and value only in paid_amount", g112721i: true do
        # Add payer user expense
        user_expense = { "0": { user_id: @user.id, owed_amount: 0, paid_amount: 100 } }
        without_split_valid_params[:expense][:user_expenses_attributes].delete(:"1")
        
        without_split_valid_params[:expense][:user_expenses_attributes].update(user_expense)
        without_split_valid_params[:expense].update({ amount: 100, split: "0" })
      
        post expenses_path, params: without_split_valid_params, xhr: true
        
        # Check request response
        expect(response).to have_http_status(200)
        expect(response.body).to include("owed shares (\\$0.0) is different than the total cost (\\$100.0)")

        # Check expense record
        expense = Expense.order(:id).last

        expect(expense).to be_nil
      end
    end

    context "InValid expense" do
      it "A user cannot create an Expense and pay the complete expense of another user without adding paid amount", g112721ga: true do
        with_split_valid_params[:expense][:user_expenses_attributes].delete(:"0")
        with_split_valid_params[:expense][:user_expenses_attributes].delete(:"1")
        post expenses_path, params: with_split_valid_params, xhr: true
        
        # Check request response
        expect(response).to have_http_status(200)
        expect(response.body).to include("Expense amount is not split with payer")

        # Check expense record
        expense = Expense.order(:id).last

        expect(expense).to be_nil
      end

      it "A user cannot create an Expense without amount", g112721ga: true do
        with_split_valid_params[:expense].delete(:amount)
        post expenses_path, params: with_split_valid_params, xhr: true
        
        # Check request response
        expect(response).to have_http_status(200)
        expect(response.body).to include("Amount: can&#39;t be blank")

        # Check expense record
        expense = Expense.order(:id).last

        expect(expense).to be_nil
      end

      it "A user cannot create an Expense without payer_id", g112721ga: true do
        with_split_valid_params[:expense].delete(:payer_id)
        post expenses_path, params: with_split_valid_params, xhr: true
        
        # Check request response
        expect(response).to have_http_status(200)
        expect(response.body).to include("Payer: must exist")

        # Check expense record
        expense = Expense.order(:id).last

        expect(expense).to be_nil
      end

      it "A user cannot create an Expense when amount is other than number", g112721ga: true do
        with_split_valid_params[:expense].update({ amount: "test" })
        post expenses_path, params: with_split_valid_params, xhr: true
        
        # Check request response
        expect(response).to have_http_status(200)
        expect(response.body).to include("Amount: is not a number")

        # Check expense record
        expense = Expense.order(:id).last

        expect(expense).to be_nil
      end

      it "A user cannot create an Expense with amount that has more than 2 digits in decimal position", g112721ga: true do
        with_split_valid_params[:expense].update({ amount: 12.32323423423423423 })
        post expenses_path, params: with_split_valid_params, xhr: true
        
        # Check request response
        expect(response).to have_http_status(200)
        expect(response.body).to include("Amount: is invalid")

        # Check expense record
        expense = Expense.order(:id).last

        expect(expense).to be_nil
      end
    end
  end
end
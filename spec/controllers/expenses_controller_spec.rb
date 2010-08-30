require 'spec_helper'

describe ExpensesController do
  before(:each) do
    @event = Event.create(:name=>'Och AYE')
  end
  describe "creating expense" do
    describe "successfully" do
      before(:each) do
        post :create, :expense=>{:description=>'Haggis', :amount=>'45.50'}, :event_id=>@event.id.to_s
      end

      it "should add the expense to the event, and save" do
        @event.reload.fixed_expenses.size.should == 1
        @event.fixed_expenses.first.description.should == 'Haggis'
        @event.fixed_expenses.first.amount.should == 45.50
      end

      it "should add redirect to the expenses list" do
        response.should redirect_to event_expenses_path(@event.id)
      end
    end

    describe "unsuccessfully" do
      before(:each) do
        post :create, :expense=>{}, :event_id=>@event.id.to_s
      end

      it "should render the index" do
        response.should be_success
        response.should render_template 'index'
      end

      it "should assign the expense and event" do
        assigns(:event).should_not be_nil
        assigns(:expense).should_not be_nil
      end

      it "should not add the expense to the event" do
        assigns(:event).fixed_expenses.should be_empty
      end
    end
  end


  describe "operating on an expense" do
    before(:each) do
      @event.fixed_expenses << Expense.new(:description=>'Venue', :amount=>1200)
      @event.fixed_expenses << Expense.new(:description=>'Keynote expense',:amount=>500)
      @event.save!
      get :edit, :event_id=>@event.id.to_s, :id=>@event.fixed_expenses.first.id.to_s
    end
    describe "edit" do
      before(:each) do
        get :edit, :event_id=>@event.id.to_s, :id=>@event.fixed_expenses.first.id.to_s
      end

      it "should assign the expense and show the edit page" do
        response.should be_success
        response.should render_template 'edit'
        assigns(:expense).should_not be_nil
        assigns(:expense).should == @event.fixed_expenses.first
      end

    end

    describe "destroy" do
      before(:each) do
        @deleted_id = @event.fixed_expenses.last.id.to_s
        delete :destroy, :event_id=>@event.id.to_s, :id=>@deleted_id
      end

      it "should destroy the expense" do
        @event.reload.fixed_expenses.size.should == 1
        @event.fixed_expenses.first.id.to_s.should_not == @deleted_id
      end

      it "should redirect to index" do
        response.should redirect_to event_expenses_path(@event.id)
      end

    end

    describe "update" do

      def expense_updated
        @event.reload.fixed_expenses.last
      end

      describe "valid" do
        before(:each) do
          put :update, :event_id=>@event.id.to_s, :id=>expense_updated.id.to_s, :expense=>{:description=>'Big Venue', :amount=>2500}
        end

        it "should redirect to index" do
          #response.should redirect_to event_expenses_path(@event.id)
        end

        it "should update the expense" do
          expense_updated.amount.should == 2500
          expense_updated.description.should == 'Big Venue'
        end
      end

      describe "invalid" do
        before(:each) do
          put :update, :event_id=>@event.id.to_s, :id=>expense_updated.id.to_s, :expense=>{:description=>'', :amount=>2500}
        end

        it "should render edit" do
          response.should render_template('edit')
        end

        it "should not update the expense" do
          expense_updated.description.should =='Keynote expense'
        end

      end
    end

  end



  after(:each) do
    Event.all.each {|e| e.destroy}
  end

end

require 'spec_helper'
require 'expenses_controller_spec_base'

describe FixedExpensesController do
  include ExpensesControllerSpec

  def expenses
    @event.fixed_expenses
  end

  def assigned_expenses
    assigns(:event).fixed_expenses
  end

  def expenses_path
    event_fixed_expenses_path(@event.id)
  end


end
class Transaction < ActiveRecord::Base
  belongs_to :portfolio
  belongs_to :account, :through => :portfolio
  belongs_to :action
  belongs_to :status, :class_name => "TransactionStatus"

  attr_accessible :cost, :count, :currency, :fee, :target, :time_opened, :time_closed

  def confirm

  end

  def cancel

  end
  
end

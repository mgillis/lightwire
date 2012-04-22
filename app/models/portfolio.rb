class Portfolio < ActiveRecord::Base
  belongs_to :account
  has_many :stock_assets
  has_many :currency_assets
  has_many :transactions
  attr_accessible :name
end

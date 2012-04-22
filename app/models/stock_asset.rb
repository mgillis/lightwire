class StockAsset < ActiveRecord::Base
  belongs_to :portfolio
  attr_accessible :amount, :currency, :margin_rate
end

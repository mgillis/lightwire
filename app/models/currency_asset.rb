class CurrencyAsset < ActiveRecord::Base
  belongs_to :portfolio
  attr_accessible :amount
end

class Account < ActiveRecord::Base
  has_many :portfolios

  attr_accessible :name, :api_key
end

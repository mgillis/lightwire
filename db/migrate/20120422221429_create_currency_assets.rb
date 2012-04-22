class CreateCurrencyAssets < ActiveRecord::Migration
  def change
    create_table :currency_assets do |t|
      t.references :portfolio, :null => false
      t.decimal :amount, :null => false
    end
    add_index :currency_assets, :portfolio_id
  end
end

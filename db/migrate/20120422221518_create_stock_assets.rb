class CreateStockAssets < ActiveRecord::Migration
  def change
    create_table :stock_assets do |t|
      t.references :portfolio, :null => false
      t.string :currency, :limit => 3, :null => false
      t.decimal :amount, :null => false
      t.decimal :margin_rate
    end
    add_index :stock_assets, :portfolio_id
  end
end

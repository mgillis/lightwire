class CreateStockAssets < ActiveRecord::Migration
  def change
    create_table :stock_assets do |t|
      t.references :portfolio, :null => false
      t.string :currency, :limit => 3, :null => false
      t.string :symbol, :null => false
      t.integer :amount, :null => false
    end
    add_index :stock_assets, [:portfolio_id, :symbol]
  end
end

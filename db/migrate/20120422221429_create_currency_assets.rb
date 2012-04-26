class CreateCurrencyAssets < ActiveRecord::Migration
  def change
    create_table :currency_assets do |t|
      t.references :portfolio, :null => false
      t.decimal :amount, :null => false, :precision => 15, :scale => 3
      t.string :iso, :limit => 3, :null => false
    end
    add_index :currency_assets, [:portfolio_id, :iso]
  end
end

class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.references :portfolio, :null => false
      t.string :currency, :null => false
      t.decimal :cost, :null => false, :precision => 15, :scale => 3
      t.integer :count, :null => false
      t.decimal :fee, :null => false, :precision => 15, :scale => 3
      t.string :target, :null => false
      t.references :action, :null => false
      t.datetime :time_opened, :null => false
      t.datetime :time_closed
      t.references :transaction_status, :null => false
    end
    add_index :transactions, :portfolio_id
    add_index :transactions, :action_id
  end
end

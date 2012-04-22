class CreatePortfolios < ActiveRecord::Migration
  def change
    create_table :portfolios do |t|
      t.references :account, :null => false
      t.string :name, :null => false
      t.string :base_currency, :limit => 3, :null => false

      t.timestamps
    end
    add_index :portfolios, :account_id
  end
end

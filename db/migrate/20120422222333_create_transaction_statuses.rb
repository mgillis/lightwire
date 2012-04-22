class CreateTransactionStatuses < ActiveRecord::Migration
  def change
    create_table :transaction_statuses do |t|
      t.string :name
    end
  end
end

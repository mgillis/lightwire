class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.string :name
    end
  end
end

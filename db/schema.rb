# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120422222333) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.string   "api_key"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "actions", :force => true do |t|
    t.string "name"
  end

  create_table "currency_assets", :force => true do |t|
    t.integer "portfolio_id", :null => false
    t.decimal "amount",       :null => false
  end

  add_index "currency_assets", ["portfolio_id"], :name => "index_currency_assets_on_portfolio_id"

  create_table "portfolios", :force => true do |t|
    t.integer  "account_id",                 :null => false
    t.string   "name",                       :null => false
    t.string   "base_currency", :limit => 3, :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "portfolios", ["account_id"], :name => "index_portfolios_on_account_id"

  create_table "stock_assets", :force => true do |t|
    t.integer "portfolio_id",              :null => false
    t.string  "currency",     :limit => 3, :null => false
    t.decimal "amount",                    :null => false
    t.decimal "margin_rate"
  end

  add_index "stock_assets", ["portfolio_id"], :name => "index_stock_assets_on_portfolio_id"

  create_table "transaction_statuses", :force => true do |t|
    t.string "name"
  end

  create_table "transactions", :force => true do |t|
    t.integer  "portfolio_id",          :null => false
    t.string   "currency",              :null => false
    t.decimal  "cost",                  :null => false
    t.integer  "count",                 :null => false
    t.decimal  "fee",                   :null => false
    t.string   "target",                :null => false
    t.integer  "action_id",             :null => false
    t.datetime "time_opened",           :null => false
    t.datetime "time_closed"
    t.integer  "transaction_status_id", :null => false
  end

  add_index "transactions", ["action_id"], :name => "index_transactions_on_action_id"
  add_index "transactions", ["portfolio_id"], :name => "index_transactions_on_portfolio_id"

end

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

TransactionStatus.create(name: 'open')
TransactionStatus.create(name: 'complete')
TransactionStatus.create(name: 'cancelled')

Action.create(name: 'buy')
Action.create(name: 'sell')

Account.create(name: 'test1', api_key: 'abcdef')
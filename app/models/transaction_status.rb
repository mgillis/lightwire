class TransactionStatus < ActiveRecord::Base
  attr_accessible :name

  self.all.each do |record|
  	class_eval <<-RUBY, __FILE__, __LINE__
  		def self.#{record.name.upcase}
  		  if @#{record.name}.nil?
  		  	@#{record.name} = self.find_by_name('#{record.name}')
  		  end
  		  @#{record.name}
  		end
  	RUBY
  end
end

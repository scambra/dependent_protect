class Company < ActiveRecord::Base
  has_many :companies, :foreign_key => 'client_of', :order => 'id', :dependent => :protect
end

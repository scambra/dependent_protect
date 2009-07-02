require 'rubygems'
require 'active_record'
require 'active_record/base'
require 'active_record/reflection'
require 'active_record/associations'
require 'ostruct'

module Associations
  def companies
    cs = OpenStruct.new
    cs.with_companies = @with_companies
    def cs.find(arg)
      self.with_companies
    end
    return cs
  end
  
  def company
    @with_company
  end
  
  def main_company
    @with_main_company
  end
end

# Mocking everything necesary to test the plugin.
class Company
  def initialize(with_or_without)
    @with_companies = with_or_without == :with_companies
    @with_company = with_or_without == :with_company
    @with_main_company = with_or_without == :with_main_company
    self.class.send :before_destroy, nil
    self.class.send :has_many, :companies, :dependent => :protect if @with_companies
    self.class.send :has_one, :company, :dependent => :protect if @with_company
    self.class.send :belongs_to, :main_company, :dependent => :protect, :class_name => 'Company' if @with_main_company
    class_eval { include Associations }
  end
  
  def self.class_name
    self.name
  end
  
  # not the real signature of the method, but forgive me
  def self.before_destroy(s=nil)
    @@before = s
  end
  # not the real signature of the method, but forgive me
  def self.after_destroy(s=nil)
    @@after = s
  end
  
  def destroy
    eval(@@before) if @@before
  end
  
  include ActiveRecord::Reflection
  include ActiveRecord::Associations
  include DependentProtect
end

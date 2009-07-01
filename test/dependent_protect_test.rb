require 'rubygems'
require 'active_record'
require 'active_record/base'
require 'active_record/reflection'
require 'active_record/associations'
require 'test/unit'
require 'ostruct'
require File.join(File.dirname(__FILE__), '..', 'lib', 'dependent_protect')

class DependentProtectTest < Test::Unit::TestCase
  
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
  
  def test_destroy_protected_with_companies
    puts "with copanies"
    protected_firm = Company.new(:with_companies)
    assert_raises(ActiveRecord::ReferentialIntegrityProtectionError) { protected_firm.destroy }
  end
  
  def test_destroy_protected_with_company
    protected_firm = Company.new(:with_company)
    assert_raises(ActiveRecord::ReferentialIntegrityProtectionError) { protected_firm.destroy }
  end
  
  def test_destroy_protected_with_main_company
    protected_firm = Company.new(:with_main_company)
    assert_raises(ActiveRecord::ReferentialIntegrityProtectionError) { protected_firm.destroy }
  end
  
  def test_destroy_protected_without_companies
    protected_firm_without_companies = Company.new(:without_companies)
    assert_nothing_raised { protected_firm_without_companies.destroy }
  end
  
  def test_destroy_protected_without_company
    protected_firm_without_company = Company.new(:without_company)
    assert_nothing_raised { protected_firm_without_company.destroy }
  end
  
  def test_destroy_protected_without_main_company
    protected_firm_without_main_company = Company.new(:without_main_company)
    assert_nothing_raised { protected_firm_without_main_company.destroy }
  end
  
  def test_old_dependent_options
    assert_nothing_raised { Company.send(:has_many, :test1, { :dependent => :destroy }) }
    assert_nothing_raised { Company.send(:has_many, :test2, { :dependent => :delete_all }) }
    assert_nothing_raised { Company.send(:has_many, :test3, { :dependent => :nullify }) }
    assert_nothing_raised { Company.send(:has_many, :test4) }
    assert_nothing_raised { Company.send(:has_one, :test5, { :dependent => :destroy }) }
    assert_nothing_raised { Company.send(:has_one, :test6, { :dependent => :delete }) }
    assert_nothing_raised { Company.send(:has_one, :test7, { :dependent => :nullify }) }
    assert_nothing_raised { Company.send(:has_one, :test8) }
    assert_nothing_raised { Company.send(:belongs_to, :test9, { :dependent => :destroy }) }
    assert_nothing_raised { Company.send(:belongs_to, :test10, { :dependent => :delete }) }
    assert_nothing_raised { Company.send(:belongs_to, :test11) }
  end
  
  def test_bad_dependent_option
    assert_raises(ArgumentError) { Company.send(:has_many, :test12, { :dependent => :bad_option }) }
    assert_raises(ArgumentError) { Company.send(:has_one, :test13, { :dependent => :bad_option }) }
    assert_raises(ArgumentError) { Company.send(:belongs_to, :test14, { :dependent => :bad_option }) }
  end

end

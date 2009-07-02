require 'test/unit'
require File.join(File.dirname(__FILE__), '..', 'lib', 'dependent_protect')
require File.join(File.dirname(__FILE__), 'company')

class DependentProtectTest < Test::Unit::TestCase
  def test_destroy_protected_with_companies
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

require File.dirname(__FILE__) + '/test_helper'

class DependentProtectTest < Test::Unit::TestCase
  fixtures :companies
  
  def test_destroy_protected_with_companies
    protected_firm = companies(:protected_firm)
    assert_equal [companies(:soft_company), companies(:too_good_software)], protected_firm.companies
    assert_raises(ActiveRecord::ReferentialIntegrityProtectionError) { protected_firm.destroy }
    protected_firm.reload
    assert_equal companies(:soft_company).reload.client_of, protected_firm.id
    assert_equal companies(:too_good_software).reload.client_of, protected_firm.id
  end
  
  def test_destroy_protected_without_companies
    protected_firm_without_companies = companies(:protected_firm_without_companies)
    assert_equal [], protected_firm_without_companies.companies
    assert_nothing_raised { protected_firm_without_companies.destroy }
    assert protected_firm_without_companies.frozen?
  end
  
  def test_old_dependent_options
    assert_nothing_raised { Company.send(:has_many, :test1, { :dependent => :destroy }) }
    assert_nothing_raised { Company.send(:has_many, :test2, { :dependent => true }) }
    assert_nothing_raised { Company.send(:has_many, :test3, { :dependent => :delete_all }) }
    assert_nothing_raised { Company.send(:has_many, :test4, { :dependent => :nullify }) }
    assert_nothing_raised { Company.send(:has_many, :test5, { :dependent => nil }) }
    assert_nothing_raised { Company.send(:has_many, :test6, { :dependent => false }) }
    assert_nothing_raised { Company.send(:has_many, :test7) }
  end
  
  def test_bad_dependent_option
    assert_raises(ArgumentError) { Company.send(:has_many, :test8, { :dependent => :bad_option }) }
  end

end

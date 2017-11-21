#!/usr/bin/ruby -w

# 

#require "repository.rb"
require "minitest/autorun"

#=============================================================================
class TestAcceptance < Minitest::Test 

  @@start_dir = Dir.pwd  # save the starting dir to restore later

  #----------------------------------------------------------------------
  def setup
    # runs before every test
    # wipe and recreate .test directory, switch pwd 
    Dir.chdir(@@start_dir)
    if File.exist?('.test')
        FileUtils.rm_rf('.test')
    end
    
    Dir.mkdir('.test')
    Dir.chdir('.test')
  end

  #----------------------------------------------------------------------
  def teardown
    # runs after every test
    Dir.chdir(@@start_dir)
    if File.exist?('.test')
        FileUtils.rm_rf('.test')
    end
    if File.exist?('.repository')
        FileUtils.rm_rf('.repository')
    end
    #super
  end
  
  #----------------------------------------------------------------------
  def test_a
    # Simple test of create, status, add, delete, commit, and history.
    
    result = `'../../hg' create`
    puts result
    assert_equal(result, "NEW REPOSITORY CREATED\n")    
    
  end

end



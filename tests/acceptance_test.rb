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
  def test_1
    # Simple test of create, status, add, delete, commit, and history.
    
    result = `'../../hg' create`
    assert_equal(result, "NEW REPOSITORY CREATED\n")    

    result = `'../../hg' history`
    assert_equal(result, "Revision #0; Parent(s): []\n")

    result = `'../../hg' status`
    assert_equal(result,     
      "REPOSITORY STATUS\n" +
      "Repository No: 0\n\n" +
      "...Files staged:\n" +
      "...Files changed from .staged version:\n\n" +
      "...Files changed from current revision:\n")
    
    `touch file1.txt`
    result = `'../../hg' add file1.txt`
    result = `'../../hg' status`
    assert_equal(result, 
      "REPOSITORY STATUS\n" +
      "Repository No: 0\n\n" +
      "...Files staged:\n" +
      "file1.txt\n\n" +
      "...Files changed from .staged version:\n\n" +
      "...Files changed from current revision:\n")

    result = `'../../hg' delete file1.txt`
    result = `'../../hg' status`
    assert_equal(result,     
      "REPOSITORY STATUS\n" +
      "Repository No: 0\n\n" +
      "...Files staged:\n" +
      "...Files changed from .staged version:\n\n" +
      "...Files changed from current revision:\n")

    result = `'../../hg' add file1.txt`
    result = `'../../hg' status`
    assert_equal(result, 
      "REPOSITORY STATUS\n" +
      "Repository No: 0\n\n" +
      "...Files staged:\n" +
      "file1.txt\n\n" +
      "...Files changed from .staged version:\n\n" +
      "...Files changed from current revision:\n")

    result = `'../../hg' commit`
    result = `'../../hg' status`
    assert_equal(result, 
      "REPOSITORY STATUS\n" +
      "Repository No: 1\n\n" +
      "...Files staged:\n" +
      "...Files changed from .staged version:\n\n" +
      "...Files changed from current revision:\n")

    result = `'../../hg' history`
    assert_equal(result, 
      "Revision #0; Parent(s): []\n" +
      "Revision #1; Parent(s): [0]\n")
  end

  #----------------------------------------------------------------------
  def test_2
    # Test that the system gracefully provides error message when commands 
    # attempted in a directory that is not a repository
    
    result = `'../../hg' status`
    assert_equal(result,     
      "WARNING: no local repository exists...use create\n" +
      "WARNING: status ignored\n")
    
    result = `'../../hg' history`
    assert_equal(result,     
      "WARNING: no local repository exists...use create\n" +
      "WARNING: history ignored\n")
    
    result = `'../../hg' add`
    assert_equal(result,     
      "WARNING: no local repository exists...use create\n" +
      "WARNING: add ignored\n")    
  end

  #----------------------------------------------------------------------
  def test_3
    # Test that the system gracefully provides error message when attempting a 
    # commit when there are no staged changes
    
    result = `'../../hg' commit`
    assert_equal(result,     
      "WARNING: no local repository exists...use create\n" +
      "WARNING: commit ignored\n")

    `../../hg create`
    result = `'../../hg' commit`
    assert_equal(result,     
      "WARNING: no files staged to commit, commit ignored\n") 
  end
end



#!/usr/bin/ruby -w

# 

require_relative "repository"
require "minitest/autorun"

#=============================================================================
class TestRepository < Minitest::Test 

  def setup
    
  end
  
  # check to see if framework is working
  def test_simple
    assert_equal(4, 2+2)
    assert_equal(6, 2*3) 
  end

  #----------------------------------------------------------------------
  def test_create
    if File.exist?('.test')
      FileUtils.rm_rf('.test')
    end
    Dir.mkdir('.test')
    Dir.chdir('.test')
    Repository.create()
    assert(File.exist?('.repository'))
    assert(File.exist?('.repository/.stage'))
    Dir.chdir('..')
    FileUtils.rm_rf('.test')
  end

  #----------------------------------------------------------------------
  def test_status
    # tests blank status
    if File.exist?('.test')
      FileUtils.rm_rf('.test')
    end
    Dir.mkdir('.test')
    Dir.chdir('.test')
    Repository.create()
    Repository.status()
    Dir.chdir('..')
    FileUtils.rm_rf('.test')
  end

  #----------------------------------------------------------------------
  def test_status2
    # adds a file and checks if in status
    if File.exist?('.test')
      FileUtils.rm_rf('.test')
    end
    Dir.mkdir('.test')
    Dir.chdir('.test')
    Repository.create()
    File.open('file1.txt', 'w') { |f| f.write("test text") }
    Repository.status()
    Dir.chdir('..')
    FileUtils.rm_rf('.test')
  end

  #----------------------------------------------------------------------
  def test_add
    if File.exist?('.test')
      FileUtils.rm_rf('.test')
    end
    Dir.mkdir('.test')
    Dir.chdir('.test')
    Repository.create()
    FileUtils.touch('.test_file1')
    a = ['.test_file1']
    Repository.add(a)      
    Repository.status()
    Dir.chdir('..')
    FileUtils.rm_rf('.test')
  end

  #----------------------------------------------------------------------
  def test_delete
    # TODO
    
    
  end

end



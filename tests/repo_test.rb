#!/usr/bin/ruby -w

# 

require "repository.rb"
require "minitest/autorun"

#=============================================================================
class TestRepository < Minitest::Test 

  def setup
    # placeholder in case we want to setup test env    
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



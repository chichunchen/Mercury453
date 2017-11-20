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
    Repository.delete(a)
    Repository.status()
    Dir.chdir('..')
    FileUtils.rm_rf('.test')
  end

  def test_commit_one_file
    if File.exist?('.test')
      FileUtils.rm_rf('.test')
    end
    Dir.mkdir('.test')
    Dir.chdir('.test')
    Repository.create()
    FileUtils.touch('.test_file1')
    a = ['.test_file1']
    Repository.add(a)      
    Repository.commit()
    Dir.chdir('..')
    FileUtils.rm_rf('.test')
  end

  # This test add one file at a time and then commit for 101 times
  def test_commit_stress_1
    if File.exist?('.test')
      FileUtils.rm_rf('.test')
    end
    Dir.mkdir('.test')
    Dir.chdir('.test')
    Repository.create()

    # should be 1000, since we wrote 1000 in our acceptance test
    (0..100).each do |e|    
      filename = '.test_file' + e.to_s
      FileUtils.touch(filename)
      a = [filename]
      Repository.add(a)      
      Repository.commit()
    end
    Dir.chdir('..')
    FileUtils.rm_rf('.test')
  end

  def test_checkout
    if File.exist?('.test')
      FileUtils.rm_rf('.test')
    end
    Dir.mkdir('.test')
    Dir.chdir('.test')
    Repository.create()

    FileUtils.touch('.test_file1')
    a = ['.test_file1']
    Repository.add(a)      
    Repository.commit()

    FileUtils.touch('.test_file2')
    b = ['.test_file2']
    Repository.add(b)
    Repository.commit()

    Repository.checkout(1)
    Dir.chdir('..')
    FileUtils.rm_rf('.test')
  end

  def test_merge
    if File.exist?('.test')
      FileUtils.rm_rf('.test')
    end
    Dir.mkdir('.test')
    Dir.chdir('.test')
    Repository.create()
    FileUtils.touch('.test_file1')
    a = ['.test_file1']
    Repository.add(a)      
    Repository.commit()

#    FileUtils.chdir('..')
#    FileUtils.mkdir('.test2')
#    Dir.glob('.test/*') {|f| FileUtils.cp File.expand_path(f), '.test2/' }
#    FileUtils.chdir('.test')
#    Repository.merge()

    Dir.chdir('..')
    FileUtils.rm_rf('.test')
    FileUtils.rm_rf('.test2')
  end

  # Repository doesn't have version yet
  def test_version_message
    if File.exist?('.test')
      FileUtils.rm_rf('.test')
    end
    Dir.mkdir('.test')
    Dir.chdir('.test')
    Repository.create()
    FileUtils.touch('.test_file1')
    a = ['.test_file1']
    Repository.add(a)      
    Repository.commit()
    #Repository.version()
    Dir.chdir('..')
    FileUtils.rm_rf('.test')
  end

  # Repository doesn't have help yet
  def test_help_message
    if File.exist?('.test')
      FileUtils.rm_rf('.test')
    end
    Dir.mkdir('.test')
    Dir.chdir('.test')
    Repository.create()
    #Repository.help()
    Dir.chdir('..')
    FileUtils.rm_rf('.test')
  end

  def test_merge_history
    if File.exist?('.test')
      FileUtils.rm_rf('.test')
    end
    Dir.mkdir('.test')
    Dir.chdir('.test')
    Dir.mkdir('repo1')
    Dir.chdir('repo1')
    Repository.create()
    File.open('f.txt','w') do |f|
        f.write(" ")
    end
    Repository.commit()
    Dir.chdir('..')
    Dir.mkdir('repo2')
    Dir.chdir('repo2')
    Repository.create()
    File.open('f.txt','w') do |f|
        f.write("a")
    end
    Repository.merge('../repo1')
    Dir.chdir('..')
    FileUtils.rm_rf('.test')
 
  end

end



#!/usr/bin/ruby -w

# 

require "repository.rb"
require "minitest/autorun"

#=============================================================================
class TestRepository < Minitest::Test 

  @@start_dir = Dir.pwd  # save the starting dir to restore later

  #----------------------------------------------------------------------
  def setup
    # wipe and recreate .test directory 
    Dir.chdir(@@start_dir)
    if File.exist?('.test')
        FileUtils.rm_rf('.test')
    end
    
    # NOTE: I don't think we want to kill .repository in pwd from running test
    if File.exist?('.repository')
       FileUtils.rm_rf('.repository')
    end
    Dir.mkdir('.test')
    Dir.chdir('.test')
  end

  #----------------------------------------------------------------------
  def teardown
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
  def test_create
    Repository.create()
    assert(File.exist?('.repository'))
    assert(File.exist?('.repository/.stage'))
  end

  #----------------------------------------------------------------------
  def test_status
    # tests blank status
    Repository.create()
    Repository.status()
  end

  #----------------------------------------------------------------------
  def test_status2
    # adds a file and checks if in status
    Repository.create()
    File.open('file1.txt', 'w') { |f| f.write("test text") }
    Repository.status()
  end

  #----------------------------------------------------------------------
  def test_status3
    # adds a file and checks if in status
    Repository.create()
    FileUtils.touch('file1.txt')
    Repository.add(['file1.txt'])          
    FileUtils.touch('file2.txt')
    Repository.status()
    
    # add check that status shows file1.txt staged and file2.txt unstaged
    
  end

  #----------------------------------------------------------------------
  def test_add
    Repository.create()
    FileUtils.touch('.test_file1')
    a = ['.test_file1']
    Repository.add(a)      
    Repository.status()
  end

  #----------------------------------------------------------------------
  def test_delete
    Repository.create()
    FileUtils.touch('.test_file1')
    a = ['.test_file1']
    Repository.add(a)      
    Repository.status()
    Repository.delete(a)
    Repository.status()
  end

  def test_commit_one_file
    Repository.create()
    FileUtils.touch('.test_file1')
    a = ['.test_file1']
    Repository.add(a)      
    Repository.commit()
  end

  # This test add one file at a time and then commit for 101 times
  def test_commit_stress_1
    Repository.create()

    # should be 1000, since we wrote 1000 in our acceptance test
    (0..10).each do |e|    
      filename = '.test_file' + e.to_s
      FileUtils.touch(filename)
      a = [filename]
      Repository.add(a)      
      Repository.commit()
    end
  end

  def test_checkout
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
  end

  def test_fetch
    Dir.mkdir('repo1')
    Dir.chdir('repo1') do
        Repository.create()
        FileUtils.touch('file1')
        a = ['file1']
        Repository.add(a)      
        Repository.commit()
    end
    Dir.mkdir('repo2')
    Dir.chdir('repo2') do
        Repository.create()
        FileUtils.touch('file1')
        FileUtils.touch('file2')
        a = ['file1', 'file2']
        Repository.add(a)      
        Repository.commit()
        Repository.merge('../repo1')
        Repository.checkout(2)
        assert(!File.exist?('file2'), "Checkout should remove not-present files")
    end
    FileUtils.rm_rf('repo1')
    FileUtils.rm_rf('repo2')
  end

  def test_merge
    Dir.mkdir('repo1')
    Dir.chdir('repo1') do
        Repository.create()
        FileUtils.touch('file1')
        a = ['file1']
        Repository.add(a)      
        Repository.commit()
    end
    Dir.mkdir('repo2')
    Dir.chdir('repo2') do
        Repository.create()
        FileUtils.touch('file2')
        a = ['file2']
        Repository.add(a)      
        Repository.commit()
        Repository.merge('../repo1')
        assert(File.exist?('file1') && File.exist?('file2'), "Merge should incorporate all non-conflicting files")
    end
    FileUtils.rm_rf('repo1')
    FileUtils.rm_rf('repo2')
   
  end

  # Repository doesn't have version yet
  # hg is handling version, not sure if it makes sense to move to repository
  def test_version_message
    Repository.create()
    FileUtils.touch('.test_file1')
    a = ['.test_file1']
    Repository.add(a)      
    Repository.commit()
    #Repository.version()
  end

  # Repository doesn't have help yet
  # hg is handling help, not sure if it makes sense to move to repository
  def test_help_message
    Repository.create()
    #Repository.help()
  end
  
  def test_merge_history
    Dir.mkdir('repo1')
    Dir.chdir('repo1') do
        Repository.create()
        File.open('f.txt','w') do |f|
            f.write(" ")
        end
        Repository.add(['f.txt'])
        Repository.commit()
    end
    Dir.mkdir('repo2')
    Dir.chdir('repo2') do
        Repository.create()
        File.open('g.txt','w') do |f|
            f.write("a")
        end
        Repository.add(['g.txt'])
        Repository.commit()
        Repository.merge('../repo1')
    end
    FileUtils.rm_rf('repo1')
    FileUtils.rm_rf('repo2')
 
  end

  def test_clone_merge
    output, ret = Repository.collect_output do
        Dir.mkdir('repo1')
        Dir.chdir('repo1') do
            Repository.create()
            File.open('f1.txt','w') do |f|
                f.write("v1")
            end
            Repository.add(['f1.txt'])
            Repository.commit()
        end
        `cp -r repo1/ repo2/`
        Dir.chdir('repo1') do
            Repository.create()
            File.open('f2.txt','w') do |f|
                f.write("v2")
            end
            Repository.add(['f2.txt'])
            Repository.commit()
        end
        Dir.chdir('repo2') do
            Repository.merge('../repo1')
        end
    end
    assert(File.exist?('repo2/f1.txt'))
    assert(File.exist?('repo2/f2.txt'))
  end

end



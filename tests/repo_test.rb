require 'repository'
require 'minitest/autorun'

#=============================================================================
class TestRepository < Minitest::Test 

  def setup
    
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
    assert(File.exist?('.repository/.files'))
    assert(File.exist?('.repository/.stage'))
    FileUtils.rm_rf('.test')
    Dir.chdir('..')
  end

  #----------------------------------------------------------------------
  def test_status
    if File.exist?('.test')
      FileUtils.rm_rf('.test')
    end
    Dir.mkdir('.test')
    Dir.chdir('.test')
    Repository.create()
    Repository.status()
    FileUtils.rm_rf('.test')
    Dir.chdir('..')
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
    #FileUtils.rm_rf('.test')
    Dir.chdir('..')
  end

  #----------------------------------------------------------------------
  def test_delete
    # TODO
    
    
  end

end



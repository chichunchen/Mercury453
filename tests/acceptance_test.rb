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
      "file1.txt\n" +
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
      "file1.txt\n" +
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
  
  #----------------------------------------------------------------------
  def test_4
    # Test that the system gracefully provides error message when attempting to
    # add a file that doesn't exist
  end  
  
  #----------------------------------------------------------------------
  def test_5
    # Stress test, a 1000 iteration loop of adding and committing changes to 
    # a single file 
  end  
  
  #----------------------------------------------------------------------
  def test_6
    # Test checkout by committing two changes, then restoring to the first
    # version
    
  end  
  
  #----------------------------------------------------------------------
  def test_7
    # Tests merge. First commits first revision and second revision. Makes 
    # changes from first revision and then merges in as a third revision.
  end  
  
  #----------------------------------------------------------------------
  def test_8
    # Tests that the version command works.

    version_str = "Version: 0.1\n" + "License:
The MIT License (MIT)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"
    result = `'../../hg' -v`
    assert_equal(result, version_str)
    result = `'../../hg' version`
    assert_equal(result, version_str) 
    
  end  
  
  #----------------------------------------------------------------------
  def test_9
    # Tests that the help command works.
    
    help_str =  "
   #####                                          #
  #     #  #####    ####   #    #  #####          #    #
  #        #    #  #    #  #    #  #    #         #    #
  #  ####  #    #  #    #  #    #  #    #         #######
  #     #  #####   #    #  #    #  #####               #
  #     #  #   #   #    #  #    #  #                   #
   #####   #    #   ####    ####   #                   #
" + "

Open-source Distributed Control System

Authors:
  *  Chi-Chun Chen
  *  Yuening Liu
  *  Parker Riley
  *  Taylan Sen

Usage: ./hg <command>
Commands:
  create                Create a new repository in the current directory
  checkout <version>    Revert to the specified revision
  add <files>           Add the specified files to the next commit
  delete <files>        Delete the specified files from the next commit
  commit <files>        Commit the specified files or all outstanding changes
  status                Display files changed but not committed
  history               Display commit history
  merge <path>          Merge with the repository located at <path>
  help, -h              Display this information
  version, -v           Output version and copyright information
"
    
    result = `'../../hg' help`
    assert_equal(result, help_str) 

    result = `'../../hg' -h`
    assert_equal(result, help_str) 

  end  
  
  
end



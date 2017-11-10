#!/usr/bin/ruby

#require "./revolog.rb"
#require "./manifest.rb"
require 'fileutils'

#============================================================================
module Repository
  # This is the Repository module for top level dvcs functionality.

  # External methods
  def Repository.create()
    # Description: initialize current directory as a new repository
    # Precondition: current directory is not part of a repository
    # Postcondition: current directory part of a new, empty repository
    # Main procedure: determine if the current directory is already a 
    # repository;if not, create a new repository here
    # Exception: if the current directory is part of an existing repository, fail	
    puts '...Repository.create'
    if File.exist?('.repository')
      puts 'repository already exists...create ignored'
    else
      Dir.mkdir('.repository')
      FileUtils.touch('.repository/files_in')
      FileUtils.touch('.repository/files_staged')
    end
    
  end

  def Repository.checkout(revision_str) 
    # Description: restores the repository directory to how it was at the 
    # given revision
    # Precondition: the revision number is valid
    # Postcondition: the directory contents reflect how they were at the given
    # revision	
    # Main procedure: restore the manifest to the given revision (via 
    # Manifest/Revlog), then use Manifest to restore directory contents
    # Exception: if this revision number is not valid, fail
    puts('Repository.checkout not implemented')
  end

  def Repository.commit()
    # Description: commit the specified files or all outstanding changes
    # Precondition: files are staged for commit and no argument is provided, 
    # or no files are staged and some are provided as arguments
    # Postcondition: the specified files or outstanding changes are committed
    # Main procedure: if there are staged changes, commit them; if files are
    # passed as arguments, stage and commit them
    # Exception: if one or more files are staged and one or more arguments are
    # provided, fail
    puts('Repository.commit not implemented')
  end

  def Repository.add(files_list)
    # Description: add the specified files to the next commit
    # Precondition: file exists in working directory
    # Postcondition: file is staged for commit
    # Main procedure: add file to list of staged files
    # Exception: if the file does not exist, fail
    puts('Repository.add not implemented')

  end

  def Repository.delete(files_list)
    # Description: remove the specified files from the next commit
    # Precondition: file is staged for commit
    # Postcondition: file is not staged for commit
    # Main procedure: find file in list of staged files and remove it
    # Exception: if the file is not staged, fail
    puts('Repository.delete not implemented')
    
  end

  def Repository.merge(path_str)
    # Description: merge with the repository located at path.
    # Precondition: path contains a valid repository
    # Postcondition: contents and history of branch present path exist in this
    # repository
    # Main procedure: merge the two repositories first by merging their DAGs,
    # and then finding the lowest common ancestor for each file; each file is
    # merged (see Analysis document)
    # Exception: if path does not contain a repository, or if the repository 
    # is determined to be identical to the current repository, fail
    puts('Repository.mrege not implemented')
    
  end

  def Repository.status()
    # Description: display files changed but not committed
    # Precondition: current directory is a repository
    # Postcondition: directory contents that have been edited are 
    # displayed, grouped by status: staged for commit, or edited but not 
    # staged
    # Main procedure: list all files staged for commit, then find and 
    #	  display all edited but unstaged files
    # Exception: if current directory is not a repository, fail 
    if !File.exist?('.repository')
      puts('\nNOT IN A REPOSITORY...use create\n')
      return
    end

    print("\nREPOSITORY STATUS:\n")

    # print files that are staged
    puts("...Files staged:")
    if !File.exist?('.repository/files_staged')
      puts('Missing repository file files_staged')
    else
      text = File.read('.repository/files_staged')
      puts(text)
    end
    
    # print files changed but not staged
    puts("...Files changed but not staged:\n")
    # TODO
    
    # print files that are in repo
    puts("...Files in repo:")
    if !File.exist?('.repository/files_in')
      puts('Missing repository file files_in')
    else
      text = File.read('.repository/files_in')
      puts(text)
    end
    
    # print files not tracked
    puts("...Files not tracked:\n")
    # TODO
  end


  def Repository.history()
    # Description: display commit history
    # Precondition: current directory is a repository
    # Postcondition: display the history of all commits
    # Main procedure: display a list of each commit, its parent(s), revision
    # number, and commit message
    # Exception: if current directory is not a repository, fail
    puts('Repository.history not implemented')
  end	
  
  protected
  
  
  
 
end
#============================================================================

# check if repository is called from commandline, if so execute command
if __FILE__ == $0
  puts('Repository called from main')
  puts ARGV
  if ARGV[0] == 'create'
    Repository.create()
  end
else
  puts("Repository module loaded")
end
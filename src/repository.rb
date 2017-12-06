#!/usr/bin/ruby

require_relative "revlog"
require_relative "manifest"
require_relative "mergemodules/repomerge"
require 'fileutils'
require 'logger'
require 'securerandom'

$logger = Logger.new(STDOUT)
#$logger.level = Logger::ERROR
#$logger.level = Logger::WARN
$logger.level = Logger::INFO     # lets use this for stdout
#$logger.level = Logger::DEBUG

$logger.formatter = proc do |severity, datetime, progname, msg|
   "#{msg}\n"
end
  
FIRST_REV ||= 0

#============================================================================
# FILESYSTEM STATE STRUCTURE USED BY Repository
#
# all state data will be stored in the directory .repository. Repository will 
# have a subdirectory .stage and the files .commit_history and 
# current_revision.txt 
#
# Here
# is an example directory/file stucture
# 
# .repository/            # all repository state information is stored here
#   .commit_history.txt   # holds raw history of commits (for error check)
#   .current_revision.txt # hold the current revision int; starts at -1
#   .stage/               # this holds a cp of files that were added with .add()
#
#============================================================================
module Repository
  # This is the Repository module for top level dvcs functionality.

  include RepoMerge

 
  #--------------------------------------------------------------------
  def Repository.create()
    # Description:    initialize current directory as a new repository
    # Precondition:   current directory is not part of a repository
    # Postcondition:  current directory part of a new, empty repository
    # Main procedure: determine if the current directory is already a 
    #                 repository;if not, create a new repository here
    # Exception:      if the current directory is part of an existing 
    #                 repository, fail	
    # return val:     true if repository was created, false in not 

    $logger.debug('...Repository.create')
    if File.exist?('.repository')
      # TODO: consider if exception is better than warning
      $logger.warn('WARNING: repository already exists...create ignored')
      return false
    else
      # create filesystem structures
      Dir.mkdir('.repository')
      Dir.mkdir('.repository/.stage')

      Manifest.new.create
      $logger.info('NEW REPOSITORY CREATED')
      return true
    end    

  end

  #--------------------------------------------------------------------
  def Repository.checkout(revision_str) 
    # Description:    restores the repository directory to how it was at the 
    #                 given revision
    # Precondition:   the revision number is valid
    # Postcondition:  the directory contents reflect how they were at the given
    #                 revision	
    # Main procedure: restore the manifest to the given revision (via 
    #                 Manifest/Revlog), then use Manifest to restore directory
    #                 contents
    # Exception: if this revision number is not valid, fail; 
    #            if .staged not empty, fail
    
    if !File.exist?('.repository')
      $logger.warn('WARNING: no local repository exists...use create')
      $logger.warn('WARNING: checkout ignored')
      return false
    end

    # check that the revision_str is either an int or a str of an int
    if revision_str.to_i.to_s != revision_str.to_s
      $logger.warn('WARNING: checkout called without valid revision')
      $logger.warn('WARNING: checkout ignored')
      return false
    end

    # Check if there are staged files, if so, don't allow checkout.
    files = Dir[".repository/.stage/*"]
    if files.size != 0
      $logger.warn('WARNING: checkout not allowed when files are staged.')
      $logger.warn('WARNING: either commit or delete staged files first.')
      return
    end
    
    
    manifest = Manifest.new()
    begin
      manifest.checkout(Integer(revision_str))
    rescue
      $logger.error("ERROR: checkout failed, revision does not exist")
    end
  end

  #--------------------------------------------------------------------
  def Repository.commit(repo_to_pull_in=nil)
    # Description:    commit the specified files or all outstanding changes
    # Precondition:   files are staged for commit and no argument is provided, 
    #                 or no files are staged and some are provided as arguments
    # Postcondition:  the specified files or outstanding changes are committed
    # Main procedure: if there are staged changes, commit them; if files are
    #                 passed as arguments, stage and commit them
    # Exception:      if one or more files are staged and one or more arguments 
    #                 are provided, fail

    if !File.exist?('.repository')
      $logger.warn('WARNING: no local repository exists...use create')
      $logger.warn('WARNING: commit ignored')
      return false
    end

    if repo_to_pull_in == nil
      files = Dir.entries(".repository/.stage/").reject {|e| File.directory?(e)}.to_a
      if files.size == 0
        $logger.warn('WARNING: no files staged to commit, commit ignored')
        return false
      end
      cur_rev_int = Repository.cur_rev()
      new_rev_int = dag.nextrevision()
      
      # note, new_rev_hash will likely be moved to manifest
      #new_rev_hash = SecureRandom.hex
  
      $logger.debug('cur_rev_int: ' + cur_rev_int.to_s)
      $logger.debug('new_rev_int: ' + new_rev_int.to_s)
      
      #$logger.debug(files)
      manifest = Manifest.new('.')
      manifest.commit('.repository/.stage/', files, new_rev_int)
      #open('.repository/commit_history.txt', 'a') { |f|
      #   f.puts("\n" + new_rev_int.to_s)
      #}
  
      dag.add_revision(new_rev_int, cur_rev_int)
      FileUtils.rm_rf('.repository/.stage/.') 
      $logger.info("Committed revision #{new_rev_int}")
      return new_rev_int
    else
      
    end
  end

  #--------------------------------------------------------------------
  def Repository.add(files_list)
    # Description:    add the specified files to the next commit
    # Precondition:   files exist in working directory; repository was created
    # Postcondition:  files are staged for commit
    # Main procedure: add files to list of staged files
    # Exception:      if a file does not exist, print a warning, files that do 
    #                 exist will be staged
    # return value:   true if any file is added, false otherwise

    if !File.exist?('.repository')
      $logger.warn('WARNING: no local repository exists...use create')
      $logger.warn('WARNING: add ignored')
      return false
    end
    
    if !File.exist?('.repository')
      $logger.warn('NOT IN A REPOSITORY...add ignored')
      return false
    end
    
    if files_list.nil?
      $logger.warn('WARNING: add called without any files.')
      return false
    end

    ret_val = false
    files_list.each do |e|
      if !File.exist?(e)
        $logger.warn('WARNING: ' + e + ' is not a file')
        next
      end
      
      # check if file is already staged
      if File.exist?('.repository/.stage/' + e)
        $logger.info('INFO: updating staged file: ' + e)  
        FileUtils.rm('.repository/.stage/' + e)
      end
      
      FileUtils.cp(e, '.repository/.stage/' + e)      
      $logger.info('added ' + e + ' to staging area')
      ret_val = true

    end
    return ret_val
  end

  #--------------------------------------------------------------------
  def Repository.delete(files_list)
    # Description:    remove the specified files from the next commit
    # Precondition:   file is staged for commit
    # Postcondition:  file is not staged for commit
    # Main procedure: find file in list of staged files and remove it
    # Exception:      if the file is not staged, fail
    # ***NOTE***:     this command does not remove a file from a repository, it
    #                 only removes the file from staging for the next commit

    if !File.exist?('.repository')
      $logger.warn('WARNING: no local repository exists...use create')
      $logger.warn('WARNING: delete ignored')
      return false
    end

    files_list.each do |e|
      if !File.exist?('.repository/.stage/' + e)
        $logger.warn('WARNING: ' + e + ' is not currently staged')
        next
      else
        FileUtils.rm('.repository/.stage/' + e)        
      end
    end
  end

  #--------------------------------------------------------------------
  def Repository.merge(path_str)
    # Description:    merge with the repository located at path.
    # Precondition:   path contains a valid repository
    # Postcondition:  contents and history of branch present path exist in this
    # repository
    # Main procedure: merge the two repositories first by merging their DAGs,
    #                 and then finding the lowest common ancestor for each file;
    #                 each file is merged (see Analysis document)
    # Exception:      if path does not contain a repository, or if the 
    #                 repository is determined to be identical to the current 
    #                 repository, fail
    #TODO: error checking

    if !File.exist?('.repository')
      $logger.warn('WARNING: no local repository exists...use create')
      $logger.warn('WARNING: merge ignored')
      return false
    end

    mydag = dag
    myman = Manifest.new
    myrevs = mydag.each_revision(myman).to_a
    revmap = {}
    other_cur = nil
    identical = true
    path_str = File.absolute_path(path_str, Dir.pwd)
    #debug = nil

    if !Dir.exist?(path_str)
      $logger.warn('WARNING: no such path')
      $logger.warn('WARNING: merge ignored')
      return false
    end

    
    Dir.chdir(path_str) do
        if !File.exist?('.repository')
           $logger.warn('WARNING: no local repository exists in merge path')
           $logger.warn('WARNING: merge ignored')
           return false
        end
        man = Manifest.new(path_str)
        other_cur = man.current_revision
        thisdag = dag(path_str)
        $logger.debug("thisdag: #{thisdag}, for #{path_str}")
        thisdag.each_revision(man) do |revision|
            match = myrevs.find {|r| r.uuid == revision.uuid}
            if not match.nil?
                revmap[revision.revnum] = match.revnum
                next
            else
                identical = false
                newrev = mydag.nextrevision
                myman.fetch_from(man,revision.revnum,newrev,revmap)
                mydag.merge_revision_under(newrev, thisdag.parents(revision.revnum).map {|r| revmap[r]})
            end
        end
    end
    if identical
        $logger.warn("The provided repository is fully contained within this one; there is nothing to fetch.")
    else
        target_rev = revmap[other_cur]
        $logger.debug("About to merge; mydag: #{mydag}")
        conflicts = myman.merge(target_rev, mydag.nextrevision, mydag)
        conflicts.each do |fname|
            $logger.warn("Merge conflict in #{fname}")
        end
    end
    
  end

  #--------------------------------------------------------------------
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
      $logger.warn('WARNING: no local repository exists...use create')
      $logger.warn('WARNING: status ignored')
      return false
    end

    if !File.exist?('.repository/.stage')
      $logger.error('ERROR: REPOSITORY CORRUPT, .repository/.stage missing')
      return
    end

    $logger.info("REPOSITORY STATUS")

    $logger.info("Repository No: " + Repository.cur_rev.to_s + "\n")

    # print files that are staged
    $logger.info("...Files staged:")
    staged_files = Dir[".repository/.stage/*"]    
    filenames = staged_files.map {|f|  $logger.info(File.basename(f))}    
    #filenames.each {|f| $logger.info(f)}
    
    # print staged files that have changed
    $logger.info("...Files changed from .staged version:")
    staged_files.each do |f|
      f_orig = File.basename(f)
      if !File.exist?(f_orig) or !FileUtils.identical?(f,f_orig)
        $logger.info(f_orig)
      end
    end

    # print files changed but not staged
    $logger.info("\n...Files changed from current revision:")
    mani = Manifest.new('.')
    files_changed = mani.files_changed(Repository.cur_rev())
    if !files_changed.nil? 
      files_changed.each {|f| $logger.info(f)}
    end
    
    # print files not tracked
    #puts("...Files not tracked:\n")
    # TODO
  end

  #--------------------------------------------------------------------
  def Repository.history()
    # Description: display commit history
    # Precondition: current directory is a repository
    # Postcondition: display the history of all commits
    # Main procedure: display a list of each commit, its parent(s), revision
    # number, and commit message
    # Exception: if current directory is not a repository, fail

    if !File.exist?('.repository')
      $logger.warn('WARNING: no local repository exists...use create')
      $logger.warn('WARNING: history ignored')
      return false
    end

    $logger.info(dag.history)

  end

  #--------------------------------------------------------------------
  def Repository.cur_rev()
    # Returns current revision
    Manifest.new.current_revision
  end
  
end
#============================================================================

# check if repository is called from commandline, if so execute command
if __FILE__ == $0
  $logger.debug('repository.rb called from main')

  if ARGV[0]
    case ARGV[0]
    when 'create'
      Repository.create()
    when 'checkout'
      Repository.checkout(ARGV[1])
    when 'commit'
      Repository.commit()
      if ARGV.length != 1  # is it a commit with files?
          if Repository.add(ARGV[1..ARGV.length]) # only if add is successful do the commit
              Repository.commit()
          end
      else
          Repository.commit()
      end  
    when 'add'
      Repository.add(ARGV[1..ARGV.length])
    when 'delete'
      Repository.delete(ARGV[1..ARGV.length])
    when 'merge'
      Repository.merge(ARGV[1])
    when 'status'
      Repository.status()
    when 'history'
      Repository.history()
    else
      puts("unknown repository command: " + ARGV[0])
    end
  end
else
  $logger.debug("Repository module loaded")
end


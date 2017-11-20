#!/usr/bin/ruby

require_relative "revlog"
require_relative "manifest"
require_relative "mergemodules/repomerge"
require 'fileutils'
require 'logger'
require 'securerandom'

$logger = Logger.new(STDOUT)
#logger.level = Logger::ERROR
#logger.level = Logger::WARN
#logger.level = Logger::INFO
$logger.level = Logger::DEBUG

$logger.formatter = proc do |severity, datetime, progname, msg|
   "#{msg}\n"
end
  
#============================================================================
module Repository
  #============================================================================
  # temporary placeholder for Dag functionality, i.e. delete when Dag ready
  module Dag
    
    def Dag.next_rev_int()
      return rand(50)
    end
    
    def Dag.add_rev(parent_revs, new_rev_int)
      puts '...calling Dag.add_rev'
    end
  
    def Dag.history()
      puts '...calling Dag.history'
    end
    
  end

  include RepoMerge
  # This is the Repository module for top level dvcs functionality.

  # External methods
  #--------------------------------------------------------------------
  def Repository.create()
    # Description: initialize current directory as a new repository
    # Precondition: current directory is not part of a repository
    # Postcondition: current directory part of a new, empty repository
    # Main procedure: determine if the current directory is already a 
    #                 repository;if not, create a new repository here
    # Exception: if the current directory is part of an existing repository, 
    #            fail	

    puts '...Repository.create'
    if File.exist?('.repository')
      puts 'repository already exists...create ignored'
    else
      Dir.mkdir('.repository')
      Dir.mkdir('.repository/.stage')
      File.open('.repository/commit_history.txt', 'w') do |f| 
        f.write("FROM \t\t\t\tTO\n") 
      end
      File.open('.repository/current_revision.txt', 'w') do |f| 
        f.write(-1) 
      end
    end    
  end

  #--------------------------------------------------------------------
  def Repository.checkout(revision_str) 
    # Description: restores the repository directory to how it was at the 
    #              given revision
    # Precondition: the revision number is valid
    # Postcondition: the directory contents reflect how they were at the given
    #                revision	
    # Main procedure: restore the manifest to the given revision (via 
    #                 Manifest/Revlog), then use Manifest to restore directory
    #                 contents
    # Exception: if this revision number is not valid, fail
    puts('Repository.checkout not implemented')
  end

  #--------------------------------------------------------------------
  def Repository.commit()
    # Description:    commit the specified files or all outstanding changes
    # Precondition:   files are staged for commit and no argument is provided, 
    #                 or no files are staged and some are provided as arguments
    # Postcondition:  the specified files or outstanding changes are committed
    # Main procedure: if there are staged changes, commit them; if files are
    #                 passed as arguments, stage and commit them
    # Exception:      if one or more files are staged and one or more arguments 
    #                 are provided, fail

    files = Dir[".repository/.stage/*"]
    if files.size == 0
      $logger.warn('WARNING: no files staged to commit, commit ignored')
      return
    end
    cur_rev_int = Repository.cur_rev()
    new_rev_int = Dag.next_rev_int()
    
    # note, new_rev_hash will likely be moved to manifest
    new_rev_hash = SecureRandom.hex

    $logger.info('cur_rev_int: ' + new_rev_int.to_s)
    $logger.info('new_rev_hash: ' + new_rev_hash)
    $logger.info('new_rev_hash: ' + new_rev_hash)
    
    #logger.debug(files)
    manifest = Manifest.new('.')
    manifest.commit(files, new_rev_int)
    open('.repository/commit_history.txt', 'a') { |f|
       f.puts("\n" + new_rev_int.to_s)
    }
    
    
    

    #Dag.add_rev()
    FileUtils.rm_rf('.repository/.stage/.') 
  end

  #--------------------------------------------------------------------
  def Repository.add(files_list)
    # Description:    add the specified files to the next commit
    # Precondition:   files exist in working directory; repository was created
    # Postcondition:  files are staged for commit
    # Main procedure: add files to list of staged files
    # Exception:      if a file does not exist, print a warning, files that do 
    #                 exist will be staged

    if !File.exist?('.repository')
      puts('\nNOT IN A REPOSITORY...add ignored\n')
      return
    end
    
    if files_list.nil?
      puts('\nWARNING: add called without any files.\n')
      return
    end

    files_list.each do |e|
      if !File.exist?(e)
        puts('\nWARNING: ' + e + ' is not a file\n')
        next
      end
      
      # check if file is already staged
      if File.exist?('.repository/.stage/' + e)
        puts('\nINFO: updating staged file: ' + e)  
        FileUtils.rm('.repository/.stage/' + e)
      end
      
      FileUtils.cp(e, '.repository/.stage/' + e)      
    end
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

    puts('Repository.delete not tested')
    
    files_list.each do |e|
      if !File.exist?('.repository/.stage/' + e)
        puts('\nWARNING: ' + e + ' is not currently staged\n')
        next
      else
        FileUtils.rm('.repository/.stage/' + e)        
      end
    end
  end

  #--------------------------------------------------------------------
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
    puts('Repository.merge not implemented')
    #TODO: error checking
    mydag = dag
    myman = Manifest.new
    myrevs = mydag.each_revision.to_a
    revmap = {}
    Dir.chdir(path_str) do
        man = Manifest.new
        dag.each_revision(man) do |revision|
            if myrevs.map {|r| r.uuid}.include?(revision.uuid)
                revmap[revision.revnum] = revision.revnum
                next
            else
                #this is a new revision
                #change the data and commit it
                    #topological order means only new revision number is this one (make nextrevision)
                    #with every new one, modify some record that maps revision renumberings
                    #map revnum and each content's revnum (if not mapped, identity)
                newrev = Manifest::ManifestData.new
                newrev.revnum = mydag.nextrevision
                revmap[revision.revnum] = newrev.revnum
                revision.contents.each do |c|
                    newrev.add_content(revmap[c.revnum],c.fname)
                end
                #newrev should be ready to be merge_committed
                #all content revnums should be defined
                #who's the parent? : _dag.parents(revnum)
                #somedag.add_revision_under(newrevisiondata, parents, manifest)
                    #manifest.add_revision(newrevisiondata), + bookkeeping
                    #or, somemanifest.add_revision_under(newrevisiondata, parents) NOT IDEAL, PARENTS UN-NEEDED
                mydag.merge_revision_under(newrev, dag.parents(revision.revnum).map {|r| revmap[r]}, myman)
            end
        end
        #enumerate revisions in tsorted order (with uuids)
            #if matches something in me, skip it
            #else, get all files changed in that revision (revision = that revision #)
            #for each file, commit those contents as new revision
            #this is true for the manifest too! (possible content changes)
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
      puts('\nNOT IN A REPOSITORY...use create\n')
      return
    end

    if !File.exist?('.repository/.stage')
      puts('\nREPOSITORY CORRUPT, .repository/.stage missing\n')
      return
    end

    print("\nREPOSITORY STATUS:\n")

    # print files that are staged
    puts("...Files staged:")
    Dir[".repository/.stage/*"].each {|f| puts File.basename(f)}    
    
    # print staged files that have changed
    puts("...Files changed from .staged version:\n")
    Dir[".repository/.stage/*"].each do |f|
      f_orig = File.basename(f)
      if !File.exist?(f_orig) or !FileUtils.identical?(f,f_orig)
        puts f_orig
      end
    end

    # print files changed but not staged
    puts("...Files changed from current revision:\n")
    mani = Manifest.new('.')
    files_changed = mani.files_changed()
    if !files_changed.nil? 
      files_changed.each {|f| puts f}
    end
    mani = nil
    
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

    puts dag.history
    #text = File.read('.repository/commit_history.txt')
    #puts(text)
  end

  #--------------------------------------------------------------------
  def Repository.cur_rev()
    # Returns current revision
    text = File.read('.repository/current_revision.txt')
    return text.to_i()
  end
  
  #--------------------------------------------------------------------
  
  protected
  
end
#============================================================================

# check if repository is called from commandline, if so execute command
if __FILE__ == $0
  puts('Repository called from main')
  puts ARGV
  if ARGV[0]
    case ARGV[0]
    when 'create'
      Repository.create()
    when 'checkout'
      Repository.checkout(ARGV[1])
    when 'commit'
      Repository.commit()
    when 'add'
      Repository.add(ARGV[1..ARGV.length])
    when 'delete'
      Repository.delete(ARGV[1..ARGV.length])
    when 'merge'
      Repository.merge()
    when 'status'
      Repository.status()
    when 'history'
      Repository.history()
    else
      puts("unknown repository command: " + ARGV[0])
    end
  end
else
  puts("Repository module loaded")
end


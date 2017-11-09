""" INTERFACES 
    All modules public functions are listed here. Please try not to change 
    anything in this file. If you must, please let your teammates know!

"""

#============================================================================
class Repository:
  """ This is the front-end module, being the first point-of-entry for commands
  	  issued at the command line. The current working directory is used as the
  	  location for action.

      uses:
        Manifest, Revlog
  """

  # External methods
  def create(self):
    """ Description: initialize current directory as a new repository
        Precondition: current directory is not part of a repository
        Postcondition: current directory part of a new, empty repository
        Main procedure: determine if the current directory is already a 
        repository;if not, create a new repository here
        Exception: if the current directory is part of an existing repository, fail	
    """
    pass

  def checkout(self, revision_str): 
    """ Description: restores the repository directory to how it was at the 
        given revision
        Precondition: the revision number is valid
        Postcondition: the directory contents reflect how they were at the given
        revision	
        Main procedure: restore the manifest to the given revision (via 
        Manifest/Revlog), then use Manifest to restore directory contents
        Exception: if this revision number is not valid, fail
    """
    pass

  def commit(self):
    """ Description: commit the specified files or all outstanding changes
        Precondition: files are staged for commit and no argument is provided, 
        or no files are staged and some are provided as arguments
        Postcondition: the specified files or outstanding changes are committed
        Main procedure: if there are staged changes, commit them; if files are
        passed as arguments, stage and commit them
        Exception: if one or more files are staged and one or more arguments are
        provided, fail
    """
    pass

  def add(self, files_list):
    """Description: add the specified files to the next commit
       Precondition: file exists in working directory
       Postcondition: file is staged for commit
       Main procedure: add file to list of staged files
       Exception: if the file does not exist, fail
    """ 
    pass

  def delete(self, files_list):
    """ Description: remove the specified files from the next commit
        Precondition: file is staged for commit
        Postcondition: file is not staged for commit
        Main procedure: find file in list of staged files and remove it
        Exception: if the file is not staged, fail
    """
    pass

  def merge(self, path_str):
    """ Description: merge with the repository located at path.
        Precondition: path contains a valid repository
        Postcondition: contents and history of branch present path exist in this
        repository
        Main procedure: merge the two repositories first by merging their DAGs,
        and then finding the lowest common ancestor for each file; each file is
        merged (see Analysis document)
        Exception: if path does not contain a repository, or if the repository 
        is determined to be identical to the current repository, fail
    """
    pass

  def status(self):
    """ Description: display files changed but not committed
        Precondition: current directory is a repository
        Postcondition: directory contents that have been edited are 
        displayed, grouped by status: staged for commit, or edited but not 
        staged
        Main procedure: list all files staged for commit, then find and 
        display all edited but unstaged files
        Exception: if current directory is not a repository, fail 
    """
    pass


  def history(self):
    """ Description: display commit history
        Precondition: current directory is a repository
        Postcondition: display the history of all commits
        Main procedure: display a list of each commit, its parent(s), revision
        number, and commit message
        Exception: if current directory is not a repository, fail
    """
    pass	

#============================================================================
class Manifest:
  def new(self):
    pass
  
  def commit(self, files_list, new_revision_str):
    pass
  
  def checkout(self, revision_str):
    pass
  
  def merge(revision_str):
    pass

  
#============================================================================
class Revlog:
  def new(self):
    pass
  
  def content(revision_str):
    pass
  
  def commit(new_revision_str):
    pass

#=============================================================================
if __name__ == '__main__':
  pass
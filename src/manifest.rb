require_relative 'revlog'
#REVLOG_LOC = ".hg/manifest/rl"

class Manifest
    #@manlog = nil #the revlog representing this manifest file
    #@revnum

    def initialize(rootPath, revision)
        #@manlog = Revlog.new(rootPath+REVLOG_LOC) #revlog representing this manifest file
        @manlog = Revlog.new(,nil)
        @revnum = revision
    end

    def create()
    end

    def commit(filelist, newrevision)
    end

    def checkout(revision)
    end

    def files_changed()
      ## Determine which files in cwd have changed from the current revision's
      ## version.
      ## Return value is an array of filename strings

    end
    
    #WARNING: interface likely to change
    def merge(revision)
    end
end

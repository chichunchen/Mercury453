require_relative 'revlog'
#REVLOG_LOC = ".hg/manifest/rl"
HIDDEN_DIR = ".hg"
MANIFEST_NAME = "manifest"
MANIFEST_FULL_PATH = HIDDEN_DIR + "/manifest/" + MANIFEST_NAME
MANIFEST_INDEX = HIDDEN_DIR + "/manifest/index/" + MANIFEST_NAME
MANIFEST_DATA = HIDDEN_DIR + "/manifest/data/" + MANIFEST_NAME

class Manifest
    #@manlog = nil #the revlog representing this manifest file
    #@revnum

    def initialize(rootPath, revision)
        #@manlog = Revlog.new(rootPath+REVLOG_LOC) #revlog representing this manifest file
        @manlog = Revlog.new(MANIFEST_NAME, MANIFEST_DATA, MANIFEST_INDEX)
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

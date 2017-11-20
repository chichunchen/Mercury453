require_relative 'revlog'
require_relative 'mergemodules/manifestmerge'
HIDDEN_DIR ||= ".repository"
MANIFEST_NAME = "manifest.rl"
MANIFEST_REL_PATH = File.join HIDDEN_DIR, "manifest", MANIFEST_NAME
MANIFEST_INDEX_F = File.join HIDDEN_DIR, "manifest", "index", MANIFEST_NAME
MANIFEST_DATA_F = File.join HIDDEN_DIR, "manifest", "data", MANIFEST_NAME

class Manifest
    include ManifestMerge

    def initialize(basedir=nil)
        @basedir = basedir || Dir.pwd
        full_path = File.join @basedir, MANIFEST_REL_PATH 
        data_path = File.join @basedir, MANIFEST_DATA_F
        index_path = File.join @basedir, MANIFEST_INDEX_F
        @manlog = Revlog.new(full_path, data_path, index_path) #revlog representing this manifest file
    end

    def create(initialrevision)
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

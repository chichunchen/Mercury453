require_relative 'revlog'
require_relative 'mergemodules/manifestmerge'
require 'fileutils'
FIRST_REV ||= 0
FIRST_REV_UUID ||= -1
HIDDEN_DIR ||= ".repository"
MANIFEST_NAME = "manifest.rl"
MANIFEST_REL_PATH = File.join HIDDEN_DIR, "manifest", MANIFEST_NAME
MANIFEST_INDEX_F = File.join HIDDEN_DIR, "manifest", "index", MANIFEST_NAME
MANIFEST_DATA_F = File.join HIDDEN_DIR, "manifest", "data", MANIFEST_NAME

class Manifest
    include ManifestMerge

    def initialize(basedir=nil)
        @basedir = basedir || Dir.pwd
        @full_fpath = File.join @basedir, MANIFEST_REL_PATH 
        data_path = File.join @basedir, MANIFEST_DATA_F
        index_path = File.join @basedir, MANIFEST_INDEX_F
        if File.directory?(File.join @basedir, HIDDEN_DIR)
            [@full_fpath, data_path, index_path].each do |p|
                d = File.dirname(p)
                unless File.directory?(d)
                    FileUtils.mkdir_p(d)
                end
            end
        end
        @manlog = Revlog.new(@full_fpath, data_path, index_path) #revlog representing this manifest file
    end

    def create()
        newdata = ManifestData.new
        newdata.revnum = FIRST_REV
        newdata.uuid = FIRST_REV_UUID
        File.open(@full_fpath, "w") do |f|
            f.write(newdata.to_s)
        end
        @manlog.create(FIRST_REV)
    end

    #def commit(filelist, newrevision)
    def commit(filelist, newrevision, path='.repository/.stage/')
        #commit each file
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

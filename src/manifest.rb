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
        @manlog = Revlog.new(MANIFEST_REL_PATH, @basedir, data_path, index_path) #revlog representing this manifest file
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

    def files_changed(revision_int)
      ## Determine which files in cwd have changed from revision
      ## version.
      ## Return value is an array of filename strings
        changed = []
        entries = Dir.entries(@basedir).reject {|e| File.directory?(e)}
        current_data.contents.each do |c|
            if entries.include?(c.fname)
                File.open(File.join(@basedir, c.fname), 'r') do |f|
                    if not FileUtils.compare_stream(f, StringIO.new(Revlog.new(c.fname, @basedir).content(c.revnum)))
                        changed << c.fname
                    end
                end
            end
        end

          
      return changed
    end
end


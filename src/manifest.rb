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

#This is my designed simple manifest
#In my opinion, I suppose manifest is a file, and the content of each line is the revision number and the corresponding filename
#This is .rb file is only for test functions because I don't use the Revlog module

#The create method is for creating a new manifest file named 'manifest'

#the commit method is for creating a filelist, and add the newrevision into the filelist, then compare the content of the filelist with the content of manifest
#if the content of the filelist is different from the revision number inside the manifest, add the new revision number into the manifest
#in this test, I suppose all the revision number is 4 digit and other characters of each line is the file name.
#for example: a line in the manifest is '1234abc', so the revision number is '1234', and that file name is 'abc'

#the checkout method is for finding the file name by a given revision number


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

        #PRIOR VERSION:
        #@manifest = File.new('manifest','a')

    end

    #def commit(filelist, newrevision, path='.repository/.stage')
    #end

    #def checkout(revision)
=begin
        manilist = @manifest

        arr = IO.readlines('manifest')
        i = 0
        pairs = {}

        while i < arr.length
            h1 = arr[i][0,4]
            h2 = arr[i][4,arr[i].length]
            h = {h1 => h2}
            pairs = pairs.merge h
            i = i + 1
        end

        pairsrevision = pairs.keys
        pairsname = pairs.values

        #puts pairsrevision
        #puts pairsname

        #check if the input revision number is already in the manifest
        k = 0
        flag = 0
        while k < pairsrevision.length
            if pairsrevision[k] == revision
                flag = 1
                revisionnumber = k
                puts revisionnumber
                break
            else
                flag = 0
            end
            k = k + 1
        end

        #if the revision number is already in the manifest, then open the corresponding file
        if flag == 1
            puts "Find the file!"
            puts pairsname[k]
            #I plan to change the puts sentence into a File.open function in the future
        end
=end
    #end
 
    
    def files_changed(revision_int)
      ## Determine which files in cwd have changed from revision
      ## version.
      ## Return value is an array of filename strings
      return []
    end
    
    
    

end


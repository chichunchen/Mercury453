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


    #def initialize(rootPath)

    #    @manlog = Revlog.new(rootPath+REVLOG_LOC)

    #end

    def create()

        @manifest = File.new('manifest','a')

    end

    def commit(filelist, newrevision)

        #create a filelist and write the new revision number inside the filelist
        flist = File.new(filelist,'w')
        flist.puts newrevision
        flist.close

        #put the lines from the filelist into an array named arr1
        arr1 = IO.readlines(flist)

        manilist = @manifest

        #put all the lines from the manifest in to an array named arr
        arr = IO.readlines('manifest')
        i = 0
        pairs = {}


        #stores each line from the manifest into a hash, the keys are the revision number(former 4 digits), and other characters are values
        while i < arr.length
            h1 = arr[i][0,4]
            h2 = arr[i][4,arr[i].length]
            h = {h1 => h2}
            pairs = pairs.merge h
            i = i + 1
        end

        pairskey = pairs.keys

        k = 0
        flag = 0

        #compares the keys with the line written in the filelist(compare if the revision number is already in the manilist)
        while k < pairskey.length
            #puts pairskey[k]
            if pairskey[k] == arr1[0][0,4]
                puts "The same as new revision!!!"
                flag = 1
                #puts flag
                break
            else
                flag = 0
                #puts flag
            end
            k = k + 1
        end

        #if the revision number is not in the manifest, write it in the manifest
        if flag == 0
            manilist.puts newrevision
            manilist.close
        end



    end

    def checkout(revision)

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

    end

end

a = Manifest.new
a.create()
a.commit('filelist1',"8888")
a.checkout("3333")


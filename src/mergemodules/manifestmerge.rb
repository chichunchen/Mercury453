module ManifestMerge
    #ManifestData = Struct.new(:revision, :uuid, :contents)

    def self.included(base)
        base.extend(ManifestClassMethods)
    end

    def data(revision)
        #use revlog to get the datums
        #parse out the three parts
    end

    module ManifestClassMethods
        
        #get Manifest by revision number
    end

end


#class Man
#    include ManifestMerge
#end

module ManifestMerge
    def self.included(base)
        base.extend(ManifestClassMethods)
    end



    module ManifestClassMethods
        
        #get Manifest by revision number
    end

end


class Man
    include ManifestMerge
end

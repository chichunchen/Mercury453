module RevlogMerge
    def self.included(base)
        base.extend(RevlogClassMethods)
    end

    def created?
        File.file?(@fname) && File.file?(@indexfile) && File.file?(@datafile) 
    end

    module RevlogClassMethods

    end
end

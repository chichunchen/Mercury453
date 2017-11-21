module RevlogMerge
    def self.included(base)
        base.extend(RevlogClassMethods)
    end

    def created?
        File.file?(@fname) && File.file?(@indexfile) && File.file?(@datafile) 
    end

    def add_revision_contents(revnum, s)
        commit(revnum, StringIO.new(s))
    end

    module RevlogClassMethods

    end
end

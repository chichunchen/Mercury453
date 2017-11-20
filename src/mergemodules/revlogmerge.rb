module RevlogMerge
    def self.included(base)
        base.extend(RevlogClassMethods)
    end

    def created?
        File.file?(@fname) && File.file?(@indexfile) && File.file?(@datafile) 
    end

    def add_revision_contents(revnum, s)
        old_content = File.read(@fname)
        open(@fname, 'w') do |f|
            f.write(s)
        end

        commit(revnum)
        
        open(@fname, 'w') do |f|
            f.write(s)
        end
    end

    module RevlogClassMethods

    end
end

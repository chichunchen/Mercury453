module ManifestMerge
    class ManifestData
        attr_accessor :revision, :uuid, :contents

        #takes an IO object (StringIO, file, whatever)
        def initialize(f=nil)
            if f
                @revision = Integer(f.first)
                @uuid = Integer(f.first)
                @contents = []
                f.each_line do |l|
                    @contents.append(l)
                end
            end
        end

        def to_s
            ls = []
            ls.append(@revision.to_s)
            ls.append(@uuid.to_s)
            @contents.each do |l|
                ls.append(l)
            end
            ls.join("\n")
        end

    end


    def self.included(base)
        base.extend(ManifestClassMethods)
    end

    def data(revision)
        if @manlog.created?
            StringIO.open(@manlog.content(revision), "r") do |f|
                ManifestData.new(f)
            end
        else
            nil
        end

    end

    module ManifestClassMethods
        
        #get Manifest by revision number
    end

end


#class Man
#    include ManifestMerge
#end

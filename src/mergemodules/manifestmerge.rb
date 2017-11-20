require 'securerandom'

module ManifestMerge
    class ManifestData
        attr_accessor :revnum, :uuid#, :contents
        attr_reader :contents

        Content = Struct.new(:revnum, :fname)

        #takes an IO object (StringIO, file, whatever)
        def initialize(f=nil)
            if f
                @revnum = Integer(f.first)
                @uuid = f.first
                @contents = []
                f.each_line do |l|
                    parts = l.split
                    @contents << Content.new(Integer.new(parts[0]),parts[1])
                end
            else
                @revnum = nil
                @uuid = newuuid
                @contents = []
            end
        end

        def to_s
            ls = []
            ls << @revnum.to_s
            ls << @uuid.to_s
            @contents.each do |l|
                ls << [l.revnum.to_s, l.fname].join(' ')
                ls << [l[0].to_s,l[1].to_s].join(' ')
            end
            ls.join("\n")
        end

        def add_content(revnum, fname)
            @contents << Content.new(revnum,fname)
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

    def add_revision(newdata)
        s = newdata.to_s
        @manlog.add_revision_contents(newdata.revnum, s)
    end

    def newuuid
        SecureRandom.hex
    end

    module ManifestClassMethods
        
    end

end

=begin

class Man
    include ManifestMerge

    def foo
        ManifestData.new
    end
end

#p Man::ManifestMerge::ManifestData.new
=end

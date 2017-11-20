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
                @uuid = ManifestMerge::newuuid
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
        #@manlog.add_revision_contents(newdata.revnum, s)
        @manlog.commit(newdata.revnum, StringIO.new(s))
    end

    def self.newuuid
        SecureRandom.hex
    end

    def newuuid
        #SecureRandom.hex
        ManifestMerge::newuuid
    end

    def commit(basedir, filelist, newrevision)
        p "MANIFEST COMMIT #{newrevision}"
        curdata = nil
        File.open(@full_fpath, 'r') do |f|
            curdata = ManifestData.new(f)
        end
        filelist.each do |fname|
            rl = Revlog.new(fname)
            File.open(File.join(basedir, fname), 'r') do |f|
                if not rl.created?
                    p "CREATING #{fname} ##{newrevision}"
                    rl.create(newrevision, f)
                else
                    rl.commit(newrevision,f)
                end
            end
        end
        newdata = ManifestData.new
        newdata.revnum = newrevision
        curdata.contents.each do |c|
            if filelist.include?(c.fname)
                c.revnum = newrevision
            end
            newdata.add_content(c.revnum, c.fname)
        end
        @manlog.commit(newrevision, StringIO.new(newdata.to_s))
        @manlog.checkout(newrevision)
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

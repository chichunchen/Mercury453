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
                    if parts.length != 2
                        next
                    end
                    @contents << Content.new(Integer(parts[0]),parts[1])
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

    def name_revlog_map(revision)
        d = data(revision)
        m = {}
        d.contents.each do |c|
            m[c.fname] = Revlog.new(c.fname, @basedir)
        end
        m
    end

    def fetch_from(otherman, otherrev, newrev, revmap)
        newdata = ManifestData.new
        newdata.revnum = newrev
        newdata.uuid = otherman.data(otherrev).uuid
        revmap[otherrev] = newrev
        rls = otherman.name_revlog_map(otherrev)
        otherman.data(otherrev).contents.each do |c|
            newdata.add_content(revmap[c.revnum], c.fname)
            r = Revlog.new(c.fname, @basedir)
            myrev = revmap[c.revnum]
            myfilecontent = StringIO.new(rls[c.fname].content(c.revnum)) 
            if r.created?
                r.commit(myrev, myfilecontent)
            else
                r.create(myrev, myfilecontent)
            end
        end
        add_revision(newdata)
    end

    def add_revision(newdata)
        s = newdata.to_s
        @manlog.commit(newdata.revnum, StringIO.new(s))
    end

    def self.newuuid
        SecureRandom.hex
    end

    def newuuid
        ManifestMerge::newuuid
    end

    def current_data
        File.open(@full_fpath, 'r') do |f|
            ManifestData.new(f)
        end
    end

    def current_revision
        current_data.revnum
    end

    def merge(revision, newrevision, rdag) #might need dag; could be cleaner with passed lambda or something; 
        #TODO: finish
        #TODO: make sure not called on ancestors
        curdata = current_data
        mergedata = data(revision)
        newdata = ManifestData.new
        newdata.revnum = newrevision
        #resolve conflicts, and copy non-conflicting members of curdata
        conflicts = []
        curdata.contents.each do |cc|
            found = false
            mergedata.contents.each do |mc|
                if cc.fname == mc.fname && cc.revnum != mc.revnum
                    lca, low = rdag.LCA(cc.revnum, mc.revnum)
                    if not lca
                        #linear; use lower
                        newdata.add_content(low, cc.fname)
                    else
                        #TODO: resolve conflict
                        #diff3
                        #either way, use new revision number

                        #make the three files
                            #get the revlog
                        rl = Revlog.new(cc.fname,@basedir)
                            #get the three versions' contents
                        left_c = rl.content(cc.revnum)
                        left_f = File.join(HIDDEN_DIR, 'your_version.merge')
                        right_c = rl.content(mc.revnum)
                        right_f = File.join(HIDDEN_DIR, 'other_version.merge')
                        parent_c = ""
                        if lca != 0
                            parent_c = rl.content(lca)
                        end
                        parent_f = File.join(HIDDEN_DIR, 'ancestor.merge')
                            #dump them into a special place in HIDDEN_DIR
                        File.open(left_f, 'w') do |l|
                            l.write(left_c)
                        end

                        File.open(right_f, 'w') do |r|
                            r.write(right_c)
                        end
                        File.open(parent_f, 'w') do |p|
                            p.write(parent_c)
                        end

                        #diff3 _ _ _ -E -m
                        #capture output and return code
                        output = `diff3 #{left_f} #{parent_f} #{right_f} -E -m`

                        #if failed, record the file
                        if not $?.success?
                            conflicts << cc.fname
                        end

                        #nuke files
                        File.delete(left_f)
                        File.delete(right_f)
                        File.delete(parent_f)

                        #commit output as new revision in revlog
                        rl.commit(newrevision, StringIO.new(output))
                        #store it in the manifest
                        newdata.add_content(newrevision, cc.fname)
                    end
                    found = true
                end
            end
            if not found
                newdata.add_content(cc.revnum, cc.fname)
            end
        end

        #copy unique members of mergedata
        mergedata.contents.each do |mc|
            if curdata.contents.find {|cc| cc.fname == mc.fname} == nil
                newdata.add_content(mc.revnum, mc.fname)
            end
        end

        #TODO: complete, check for conflicts
        add_revision(newdata)
        checkout(newrevision)
    end

    def checkout(revision)
        @manlog.checkout(revision)
        #TODO: make this more intelligent. for now, nukes everything and then restores

        #nuke everything
        Dir.entries(@basedir).reject {|e| e == '.' || e == '..' || e.start_with?(HIDDEN_DIR)}.each do |fname|
            File.delete(File.join(@basedir, fname))
        end
        
        #restore
        curdata = current_data
        rls = name_revlog_map(revision)
        curdata.contents.each do |c|
            rls[c.fname].checkout(c.revnum)
        end
    end


    def commit(basedir, filelist, newrevision)
        curdata = current_data
        newdata = ManifestData.new
        newdata.revnum = newrevision
        filelist.each do |fname|
            if not curdata.contents.map {|c| c.fname}.include?(fname)
                newdata.add_content(newrevision, fname)
            end
            rl = Revlog.new(fname)
            File.open(File.join(basedir, fname), 'r') do |f|
                if not rl.created?
                    rl.create(newrevision, f)
                else
                    rl.commit(newrevision,f)
                end
            end
        end
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

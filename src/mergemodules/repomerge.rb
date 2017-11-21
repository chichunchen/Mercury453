require 'fileutils'
require 'tsort'

FIRST_REV ||= 0

class RevisionDAG < Hash
    include TSort

    attr_accessor :f, :base

    @@loadproc = Proc.new { |base|
        base = base || Dir.pwd
        Proc.new { |bh|
            if bh.class == RevisionDAG
                bh.f = File.absolute_path(bh.f, base)
                bh.base = base
            end
            bh
        }
    }

    def self.loadproc(base=nil)
        @@loadproc.call(base)
    end

    alias tsort_each_node each_key

    def tsort_each_child(node, &block)
        fetch(node).each(&block)
    end

    def initialize(path)
        #@f = File.absolute_path(path, Dir.pwd)
        @f = path
        @base = Dir.pwd
    end

    def init(h)
        clear
        h.each do |e|
            self[e[0]] = e[1]
        end
        save
        self
    end

    def []=(key,val)
        if key.nil?
            raise "Cannot have nil revision number!"
        end
        ret = super(key,val)
        save
        ret
    end

    def save
        self.each_key.to_a.each do |k|
            self[k].each do |e|
                self[e] ||= []
            end
        end

        File.open(@f, "w") do |f|
            f.write(Marshal::dump(self))
        end
    end

    def each_revision(man, &block)
        self.tsort.reverse.map {|revnum| man.data(revnum)}.each(&block)
    end

    def nextrevision
        max = 0
        each do |e|
            if e[0] > max
                max = e[0]
            end
            e[1].each do |e2|
                if e2 > max
                    max = e2
                end
            end
        end
        max + 1
    end

    def lowest(a,b)
        a_parents = [a]
        a_parents.each do |n|
            if n == b
                return a
            end
            a_parents += parents(n)
        end
        b_parents = [b]
        b_parents.each do |n|
            if n == a
                return b
            end
            b_parents += parents(n)
        end
        nil
    end

    def LCA(a,b)
        if a == b
            parents(n1).first
        else
            a_parents = [a]
            a_parents.each do |n|
                if n == b
                    return nil,lowest(a,b) #linear
                end
                parents(n).each do |p|
                    a_parents << p
                end
            end
            b_parents = [b]
            b_parents.each do |n|
                if n == a
                    return nil,lowest(a,b) #linear
                elsif a_parents.include?(n)
                    return n,nil
                end
                parents(n).each do |p|
                    b_parents << p
                end
            end

            raise "Couldn't find root of dag! Arguments were #{a} and #{b} for dag #{self}"
        end
    end

    def parents(node)
        ps = []
        self.each_key do |k|
            ps << k if self[k].include? node
        end
        ps
    end

    def add_revision(newrevid, parentrevid)
        self[parentrevid] << newrevid
        save
    end

    def merge_revision_under(newrevnum, parents)#, manifest)
        parents.each do |p|
            self[p] ||= []
            self[p] << newrevnum
        end
        save
    end

    def history
        s = ""
        self.each_key do |k|
            id = k
            ps = parents(k)
            s += "Revision ##{id}; Parent(s): #{ps}\n"
        end
        s.rstrip!
        s
    end

end

module RepoMerge

    def self.included(base)
        base.extend(RepoClassMethods)
    end

    module RepoClassMethods
        DAG_LOC = ".repository/revisions.marshal"
        DEFAULT_DAG = {FIRST_REV => []}
        def dag(base=nil)
            base ||= Dir.pwd
            loc = File.join(base, DAG_LOC)
            begin
                File.open(loc, "r") do |f|
                    Marshal::load(f, RevisionDAG.loadproc(nil))
                end
            rescue Errno::ENOENT
                d = File.dirname(loc)
                unless File.directory?(d)
                    FileUtils.mkdir_p(d)
                end
                d = RevisionDAG.new(loc)
                d.init(DEFAULT_DAG)
                d
            end
        end

        def dag=(val)
            d = dag
            d.init(val)
        end

    end
end

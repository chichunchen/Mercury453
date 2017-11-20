require 'fileutils'
require 'tsort'

FIRST_REV ||= 0

class RevisionDAG < Hash
    include TSort

    attr_accessor :f

    @@loadproc = Proc.new { |base|
        base = base || Dir.pwd
        Proc.new { |bh|
            if bh.class == RevisionDAG
                bh.f = File.absolute_path(bh.f, base)
            end
            bh
        }
    }

    def self.loadproc (base=nil)
        @@loadproc.call(base)
    end

    alias tsort_each_node each_key

    def tsort_each_child(node, &block)
        fetch(node).each(&block)
    end

    def initialize(path)
        #@f = File.absolute_path(path, Dir.pwd)
        @f = path
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
        ret = super(key,val)
        val.each do |e|
            self[e] ||= []
        end
        save
        ret
    end

    def save
        File.open(@f, "w") do |f|
            f.write(Marshal::dump(self))
        end
    end

    def each_revision(man, &block)
        dag.tsort.map {|revnum| man.data(revnum)}.each(&block)
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

    def parents(node)
        ps = []
        self.each_key do |k|
            ps << k if self[k].include? node
        end
        ps
    end

    def merge_revision_under(newdata, parents)#, manifest)
        #manifest.add_revision(newdata)
        Manifest.new.add_revision(newdata)
        parents.each do |p|
            self[p] << newdata.revnum    
        end
    end

    def history
        s = ""
        self.each_key do |k|
            id = k
            ps = parents(k)
            s += "Revision ##{id}; Parent(s): #{ps}\n"
        end

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
        def dag
            return @dag if @dag
            begin
                File.open(DAG_LOC, "r") do |f|
                    @dag = Marshal::load(f, RevisionDAG.loadproc(nil))
                end
            rescue Errno::ENOENT
                d = File.dirname(DAG_LOC)
                unless File.directory?(d)
                    FileUtils.mkdir_p(d)
                end
                @dag = RevisionDAG.new(DAG_LOC)
                @dag.init(DEFAULT_DAG)
                @dag
            end
        end

        def dag=(val)
            d = dag
            d.init(val)
            @dag = d
        end

    end
end


=begin

module Repo
    include RepoMerge
end

#p Repo.dag.nextrevision
Repo.dag[0] = [1,2]
Repo.dag[1] = [2]
#p Repo.dag.parents(2)
puts Repo.dag.history
#p Repo.nextrevision
#p Repo.dag
#Repo.dag[2] = []
#p Repo.dag
=end

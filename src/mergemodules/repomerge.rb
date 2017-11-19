require 'fileutils'

class BackedHash < Hash
    def initialize(f)
        @f = f
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
        save
        ret
    end

    def save
        File.open(@f, "w") do |f|
            f.write(Marshal::dump(self))
        end
    end
end

module RepoMerge
    DAG_LOC = ".repository/revisions.yaml"
    DEFAULT_DAG = {1 => []}

    def dag
        return @dag if @dag
        begin
            File.open(DAG_LOC, "r") do |f|
                @dag = Marshal::load(f)
            end
        rescue Errno::ENOENT
            d = File.dirname(DAG_LOC)
            unless File.directory?(d)
                FileUtils.mkdir_p(d)
            end
            @dag = BackedHash.new(DAG_LOC)
            @dag.init(DEFAULT_DAG)
            @dag
        end
    end

    def dag=(val)
        d = dag
        d.init(val)
        @dag = d
    end

    def nextrevision
        d = dag
        max = 0
        d.each do |e|
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
end

module Repo
    extend RepoMerge

end

#p Repo.nextrevision
#Repo.dag[1] = [2]
#p Repo.nextrevision
#p Repo.dag
#Repo.dag[2] = []
#p Repo.dag

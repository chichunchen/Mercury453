require 'fileutils'
require 'tsort'

FIRST_REV ||= 0
DAG_LOC ||= ".repository/revisions.marshal"

class RevisionDAG < Hash
    include TSort

    #attr_accessor :f, :base, :alert
    attr_accessor :base, :alert

    @@loadproc = Proc.new { |base|
        base = base || Dir.pwd
        Proc.new { |bh|
            #$logger.debug(bh.class)
            #$logger.debug(bh)
            if bh.class == String
                #bh.f = File.absolute_path(bh.f, base)
                #$logger.debug("Setting #{bh} to #{base}")
                #bh.base = base
                bh = base
                #bh.alert = false
            end
            if bh.class == TrueClass
                bh = false
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

    def initialize(base=nil)
        @base = base || Dir.pwd
        @alert = false
    end

    def watch(str)
        @alert = str
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
        if @alert
            $logger.debug("Dag labeled with #{@alert} is saving to #{DAG_LOC} in #{@base}!")
        end
        self.each_key.to_a.each do |k|
            self[k].each do |e|
                self[e] ||= []
            end
        end

        File.open(File.join(@base, DAG_LOC), "w") do |f|
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
        DEFAULT_DAG = {FIRST_REV => []}
        def dag(base=nil)
            base ||= Dir.pwd
            full_loc = File.join(base, DAG_LOC)
            begin
                File.open(full_loc, "r") do |f|
                    Marshal::load(f, RevisionDAG.loadproc(base))
                end
            rescue Errno::ENOENT
                d = File.dirname(full_loc)
                unless File.directory?(d)
                    FileUtils.mkdir_p(d)
                end
                d = RevisionDAG.new(base)
                d.init(DEFAULT_DAG)
                d
            end
        end

        def dag=(val)
            d = dag
            d.init(val)
        end

        def with_logger(l, &block)
            backup = $logger
            formatter = backup.formatter
            $logger = l
            $logger.formatter = formatter
            begin
                ret = block.call
            ensure
                $logger = backup
            end
            ret
        end

        def collect_output(level=Logger::INFO, &block)
            s = ""
            st = StringIO.new(s, 'w')
            l = Logger.new(st)
            l.level = level
            ret = with_logger(l, &block)
            return s, ret
        end

    end
end

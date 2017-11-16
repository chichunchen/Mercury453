class Revlog
    @filename = nil
    @revlogLoc = nil

    def initialize(fname, revloc=nil)
        if revloc == nil
            revloc = ".hg/revlogs/" + fname + ".rl"
        end

        @filename = fname
        @revlogLoc = revloc
    end

    #NOTE: create() instead of new(); new() is the constructor
    def create()
    end

    def content(revision)
    end

    def checkout(revision)
      ## copy the revision to current working directory
      
    end
    
    def commit(newrevision)
    end
end

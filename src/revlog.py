class Revlog:
    filename = None
    revlogLoc = None

    def __init__(fname, revloc=None):
        if revloc == None:
            revloc = ".hg/revlogs/" + filename + ".rl"

        filename = fname
        revlogLoc = revloc

    def new():
        pass

    def content(revision):
        pass

    def commit(newrevision):
        pass

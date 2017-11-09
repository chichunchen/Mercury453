from revlog import Revlog
REVLOG_LOC = "/.hg/manifest.rl"

class Manifest:
    manlog = None #the revlog representing this manifest file
    
    def __init__(rootPath):
        manlog = Revlog(rootPath+REVLOG_LOC)

    def new():
        pass

    def commit(filelist, newrevision):
        pass

    def checkout(revision):
        pass

    #WARNING: interface likely to change
    def merge(revision):
        pass

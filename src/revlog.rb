require 'fileutils'
require 'scanf'

# repository should create ./hg/index and ./hg/data for Revlog
class Revlog
    include FileUtils

    # initialize a new revlog for a given file
    def initialize(fname, datafile)
        @fname = fname
        @indexfile = File.join ".hg", "index", fname
        @datafile = File.join ".hg", "data", fname

        # initialize datafile
        cp(fname, @datafile)

        # initialize indexfile
        File.open(@indexfile, "w") do |f|
            index_write_row f, "rev", "offset", "length"
            index_write_row f, "0", "0", line_count_to_s(@datafile)
        end
    end

    #NOTE: create() instead of new(); new() is the constructor
    # add a revision
    def create()
    end

    # return the content of a given revision
    def content(revision)
        line = revision+1
        parse = parse_indexfile_line get_indexfile_line(line)
        offset = parse[1]
        length = parse[2]
        str = ""

        # read file from offset to (offset+length-1)
        (offset...(offset+length)).each do |l|
            str += IO.readlines(@datafile)[l]
        end

        str
    end

    # copy the revision to current working directory
    def checkout(revision)
        str = content revision

        # write str to current directory
        File.open(@fname, "w") do |f|
            f.write str
        end
    end
    
    # add file content as a new revision
    def commit(newrevision)
        File.open(@datafile, "a") do |append|
            File.open(@fname, "r") do |read|
                read.each_line do |line|
                    append.puts line
                end
            end
        end

        # new version is the old version plus 1
        # new offset is the last length + last offset
        parse_last_line = parse_indexfile_line get_indexfile_line(-1)
        new_offset = parse_last_line[1] + parse_last_line[2]

        File.open(@indexfile, "a") do |f|
            index_write_row f, newrevision.to_s, new_offset.to_s, line_count_to_s(@fname)
        end
    end

    private
        def index_write_row stream, *arr
            padding = 10
            arr.each do |e|
                stream.write e.ljust padding
            end
            stream.write "\n"
        end

        def line_count_to_s filename
            IO.readlines(filename).size.to_s
        end

        # return a line with given line number
        def get_indexfile_line number
            IO.readlines(@indexfile)[number]
        end

        def parse_indexfile_line line
            line.scanf("%d %d %d")
        end
end

## simple unit tests
r = Revlog.new "aaa.txt", ""
r.commit 1
r.commit 2
r.checkout 1

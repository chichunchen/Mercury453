require 'fileutils'
require 'scanf'
require 'zlib'
require_relative 'mergemodules/revlogmerge'

HIDDEN_DIR = ".repository"

# repository should create ./HIDDEN_DIR/index and ./HIDDEN_DIR/data for Revlog
class Revlog
    include FileUtils
    include RevlogMerge
    include Zlib

    # initialize a new revlog for a given file
    def initialize(fname, datafile=nil, indexfile=nil)
        @fname = File.absolute_path(fname, Dir.pwd)
        @indexfile = indexfile || (File.join HIDDEN_DIR, "index", fname)
        @datafile = datafile || (File.join HIDDEN_DIR, "data", fname)
    end

    #NOTE: create() instead of new(); new() is the constructor
    # add a revision
    def create(revision=0)
        # initialize datafile with compressed file @fname
        compress_file_lines = Deflate.deflate(File.read(@fname))
        File.open(@datafile, "w") do |f|
            f.puts compress_file_lines
        end

        # initialize indexfile
        File.open(@indexfile, "w") do |f|
            index_write_row f, "rev", "offset", "length"
            index_write_row f, revision.to_s, "0", line_count_to_s(@datafile)
        end
    end

    # return the content of a given revision
    def content(revision)
        parse = parse_indexfile_line get_indexfile_with_revision(revision)
        offset = parse[1]
        length = parse[2]
        str = ""

        # read file from offset to (offset+length-1)
        (offset...(offset+length)).each do |l|
            str += IO.readlines(@datafile)[l]
        end

        # decompress back to text
        str = Inflate.inflate(str)
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
    def commit(newrevision, content_io=nil)
        if content_io.nil?
            compress_file_lines = Deflate.deflate(File.read(@fname))
        else
            compress_file_lines = Deflate.deflate(content_io.read)
        end

        # append current file fname to datafile
        length = IO.readlines(@datafile).size

        File.open(@datafile, "a") do |append|
            append.puts compress_file_lines
        end
        length = IO.readlines(@datafile).size - length

        # new version is the old version plus 1
        # new offset is the last length + last offset
        parse_last_line = parse_indexfile_line get_indexfile_with_line(-1)
        new_offset = parse_last_line[1] + parse_last_line[2]

        File.open(@indexfile, "a") do |f|
            index_write_row(f, newrevision.to_s,
                            new_offset.to_s, length.to_s)
        end
    end

    private
        def index_write_row stream, *arr
            padding = 10
            arr.each do |e|
                stream.write(e.ljust(padding))
            end
            stream.write "\n"
        end

        def line_count_to_s filename
            IO.readlines(filename).size.to_s
        end

        # return a row with given revision number
        def get_indexfile_with_revision revision
            result = nil
            File.open(@indexfile, "r") do |f|
                f.each_line do |line|
                    row = parse_indexfile_line(line)
                    if row[0] == revision
                        result = line
                        break
                    end
                end
            end
            return result if result
        end

        # return a row with given line number
        def get_indexfile_with_line number
            IO.readlines(@indexfile)[number]
        end

        def parse_indexfile_line line
            line.scanf("%d %d %d")
        end
end

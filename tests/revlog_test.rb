require 'minitest/autorun'
require 'minitest/hooks/default'
require 'fileutils'
require 'revlog.rb'

class RevlogTest < Minitest::Test
    include Minitest::Hooks
    include FileUtils

    @@test_file = 'dumb.txt'
    @@default_path = '.repository/'

    def after_all
        # clean file system after each tests
        delete_arr = ['index', 'data']
        delete_arr.each do |dir|
            rm(Dir.glob(File.join(@@default_path, dir, '*')))
        end

        # restore dump.txt
        open(@@test_file, 'w') do |f|
            f.puts "123"
        end
    end

    def test_first_revlog_data
        r = Revlog.new @@test_file
        r.create
        raw = IO.readlines(@@test_file).join
        assert_equal(raw, r.content(0))
    end

    def test_commit_sequential
        r = Revlog.new @@test_file
        r.create
        update_text_file

        (1..10).each do |e|
            r.commit e
            raw = IO.readlines(@@test_file).join
            assert_equal(raw, r.content(e))
        end
    end

    def test_checkout_with_commit
        r = Revlog.new @@test_file
        r.create
        rev_0 = r.content(0)
        update_text_file
        r.commit 1
        update_text_file
        r.commit 2
        r.checkout 0
        assert_equal(rev_0, get_lines_from_testfile)
    end

    def test_checkout_compliated
        total_commit = 50
        checkout_version = rand(total_commit)
        r = Revlog.new @@test_file
        r.create
        (1..total_commit).each do |e|
            update_text_file
            r.commit e
        end
        rev_n = r.content checkout_version
        r.checkout checkout_version
        assert_equal(rev_n, get_lines_from_testfile)
    end

    private
        def get_lines_from_testfile
            IO.readlines(@@test_file).join
        end

        def update_text_file
            open(@@test_file, "a") do |f|
                f.puts "Hello, World"
            end
        end
end

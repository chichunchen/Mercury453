require 'minitest/autorun'
require 'minitest/benchmark'
require 'minitest/hooks/default'
require 'fileutils'
require 'revlog.rb'

class RevlogTest < Minitest::Test
    include Minitest::Hooks
    include FileUtils

    @@test_file = 'dumb.txt'
    @@default_path = '.repository/'
    @@start_dir = Dir.pwd
    
    def setup
        # placeholder in case we want to setup test env    
        Dir.chdir(@@start_dir)
        if File.exist?('.test')
            FileUtils.rm_rf('.test')
        end
        if File.exist?('.repository')
            FileUtils.rm_rf('.repository')
        end
        Dir.mkdir('.test')
        Dir.chdir('.test')

        File.open(@@test_file, 'w') do |f|
            f.puts "123"
        end
    end

    #def after_all
    def teardown
        Dir.chdir(@@start_dir)
        if File.exist?('.test')
            FileUtils.rm_rf('.test')
        end
        if File.exist?('.repository')
            FileUtils.rm_rf('.repository')
        end
        # clean file system after each tests
        #delete_arr = ['index', 'data']
        #delete_arr.each do |dir|
        #    rm(Dir.glob(File.join(@@default_path, dir, '*')))
        #end

        # restore dump.txt
        #open(@@test_file, 'w') do |f|
            #f.puts "123"
        #end
        #super
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

    def test_commit_with_contentio
        r = Revlog.new @@test_file
        r.create
        File.open('dumb.txt') do |f|
            r.commit 1, f
        end
        File.open(@@test_file) do |f|
            r.commit 2, f
        end
        raw = IO.readlines('dumb.txt').join
        assert_equal(raw, r.content(1))
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

    def test_non_sequential_1
        r = Revlog.new @@test_file
        r.create 3
        File.open('dumb.txt') do |f|
            r.commit 5, f
        end
        File.open(@@test_file) do |f|
            r.commit 7, f
        end
        raw = IO.readlines('dumb.txt').join
        assert_equal(raw, r.content(5))
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

class BenchRevlog < Minitest::Benchmark
    include Minitest::Hooks
    include FileUtils

    @@default_path = '.repository/'
    @@test_file = 'dumb.txt'
    @@upper = 50



#=====
    @@start_dir = Dir.pwd

    def setup
        # placeholder in case we want to setup test env    
        Dir.chdir(@@start_dir)
        if File.exist?('.test')
            FileUtils.rm_rf('.test')
        end
        if File.exist?('.repository')
            FileUtils.rm_rf('.repository')
        end
        Dir.mkdir('.test')
        Dir.chdir('.test')

        File.open(@@test_file, 'w') do |f|
            f.puts "123"
        end
    end

    #def after_all
    def teardown
        Dir.chdir(@@start_dir)
        if File.exist?('.test')
            FileUtils.rm_rf('.test')
        end
        if File.exist?('.repository')
            FileUtils.rm_rf('.repository')
        end
        # clean file system after each tests
        #delete_arr = ['index', 'data']
        #delete_arr.each do |dir|
        #    rm(Dir.glob(File.join(@@default_path, dir, '*')))
        #end

        # restore dump.txt
        #open(@@test_file, 'w') do |f|
        #f.puts "123"
        #end
        #super
    end


#====
=begin
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
=end

    def bench_content
        r = Revlog.new @@test_file
        r.create
        (1..@@upper).each { |e| r.commit e }
        assert_performance_linear 0.0001 do |n|
            r.content n if n < @@upper
        end
    end

    def bench_commit
        r = Revlog.new @@test_file
        r.create
        assert_performance_linear 0.001 do |n|
            r.commit n
        end
    end

    def bench_checkout
        r = Revlog.new @@test_file
        r.create
        (1..@@upper).each { |e| r.commit e }
        assert_performance_linear 0.001 do |n|
            r.checkout n if n < @@upper
        end
    end
end

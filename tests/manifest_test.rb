

gem "minitest"
require "minitest/autorun"


class ManifestTest < Minitest::Test


    $LOAD_PATH << '.'
    require "manifest.rb"	

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

        @m = Manifest.new
    end


    def after_all
        Dir.chdir(@@start_dir)
        if File.exist?('.test')
            FileUtils.rm_rf('.test')
        end
        if File.exist?('.repository')
            FileUtils.rm_rf('.repository')
        end
        super
    end


    def test_create1
    	m = Manifest.new
    	t1 = m.create()
    	assert_equal 1, t1    	
    end


    def test_create2
    	m = Manifest.new
    	m.create()
    	assert(File.exist?('.repository'))
    end


    def test_create3
    	m = Manifest.new
    	m.create()
    	assert(File.exist?('.repository/manifest'))
    	assert(File.exist?('.repository/manifest/manifest.rl'))
    end


    def test_files_changed
    	m = Manifest.new
    	m.create()
    	m.files_changed(0)
    end


    def test_newuuid
    	m = Manifest.new
    	m.create()
    	t2 = m.newuuid
    	puts t2
    	assert_equal 32, t2.length
    end


    def test_current_data
    	m = Manifest.new
    	m.create()
    	t3 = m.current_data
    	puts t3
    	#assert_equal [0,-1], t3
    end


    def test_current_revision
    	m = Manifest.new
    	m.create()
    	t4 = m.current_revision
    	assert_equal 0, t4
    end


end 










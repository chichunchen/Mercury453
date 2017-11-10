#!/usr/bin/ruby -w

# 

require_relative "repository"
require "minitest/autorun"


class TestRepository < Minitest::Test 

  # check to see if framework is working
  def test_simple
    assert_equal(4, 2+2)
    assert_equal(6, 2*3) 
  end

  # out of respect to the readers intelligence comments not added profusely :)
  def test_create
    if File.exist?('.test')
      FileUtils.rm_rf('.test')
    end
    Dir.mkdir('.test')
    Dir.chdir('.test')
    Repository.create()
    assert(File.exist?('.repository'))
    assert(File.exist?('.repository/files_in'))
    assert(File.exist?('.repository/files_staged'))
    FileUtils.rm_rf('.test')
  end

=begin
  def test_any
    t = Triple.new(1,2,3)
    if t.respond_to? :any?
      assert_equal(true, t.any?{|n| n > 2})
      assert_equal(false, t.any?{|n| n > 5})
    end
  end

  def test_chunk
    t = Triple.new(1,2,3)
    if t.respond_to? :chunk
      out = t.chunk{|n| n > 2}.to_a
      assert_equal(out, [[false, [1, 2]], [true, [3]]])
    end
  end

  def test_chunk_while
    t = Triple.new(1,2,3)
    if t.respond_to? :chunk_while
      out = t.chunk_while {|i,j| i<j}.to_a
      assert_equal(out, [[1,2,3]])
    end
  end

  def test_collect
    t = Triple.new(1,2,3)
    if t.respond_to? :collect
      assert_equal(["cat","cat","cat"],t.collect{"cat"})
    end
  end

  def test_collect_concat
    t = Triple.new(1,2,3)
    if t.respond_to? :collect_concat
      assert_equal(["cat", "cat", "cat"],t.collect_concat{"cat"})
    end
  end

  def test_count
    t = Triple.new(1,2,3)
    if t.respond_to? :count
      assert_equal(3,t.count)
    end
  end

  def test_count_item
    t = Triple.new(1,2,3)
    if t.respond_to? :count
      assert_equal(1,t.count(2))
    end
  end

  def test_count_block
    t = Triple.new(1,2,3)
    if t.respond_to? :count
      assert_equal(2,t.count{ |x| x > 1})
    end
  end

  def test_cycle
     t = Triple.new(1,2,3)
    if t.respond_to? :cycle
      assert_equal([1,2,3,1,2,3],t.cycle(2).to_a)
    end
  end
    
  def test_detect
    t = Triple.new(1,2,3)
    if t.respond_to? :detect
      assert_equal(2, t.detect {|i| i > 1})
    end
  end

  def test_drop
    t = Triple.new(1,2,3)
    if t.respond_to? :drop
      assert_equal([2,3], t.drop(1))
    end
  end

  def test_drop_while
    t = Triple.new(1,2,3)
    if t.respond_to? :drop_while
      assert_equal([2,3], t.drop_while {|i| i < 2})
    end
  end

  def test_each_cons
    t = Triple.new(1,2,3)
    if t.respond_to? :each_cons
      assert_equal(t.each_cons(2).to_a, t.each_cons(2).to_a)
    end
  end

  def test_each_entry
    t = Triple.new(1,2,3)
    if t.respond_to? :each_entry
      assert_equal([1,2,3],t.each_entry{|o| o}.to_a)
    end
  end

  def test_each_slice
    t = Triple.new(1,2,3)
    if t.respond_to? :each_slice
      out = []
      t.each_slice(1) {|i| out << i}
      assert_equal([[1],[2],[3]],out)
    end
  end

  def test_each_with_index
    t = Triple.new(1,2,3)
    if t.respond_to? :each_with_index
      out = []
      t.each_with_index{|x,i| out << [x,i]}
      assert_equal(out,[[1, 0], [2, 1], [3, 2]])
    end
  end

  def test_each_with_object
    t = Triple.new(1,2,3)
    if t.respond_to? :each_with_object
      assert_equal([2,4,6],t.each_with_object([]) {|x,a| a << x*2})
    end
  end

  def test_entries
    t = Triple.new(1,2,3)
    if t.respond_to? :entries
      assert_equal([1,2,3], t.entries)
      assert_equal([1,2,3], t.to_a)
    end
  end

  def test_find
    t = Triple.new(1,2,3)
    if t.respond_to? :find
    assert_equal(2,t.find {|i| i==2})
    end
  end

  def test_find_all
    t = Triple.new(1,2,3)
    if t.respond_to? :find_all
      assert_equal([2,3],t.find_all {|i| i > 1})
    end
  end

  def test_find_index
    t = Triple.new(1,2,3)
    if t.respond_to? :find_index
      assert_equal(1,t.find_index(2))
    end
  end

  def test_find_index_block
    t = Triple.new(1,2,3)
    if t.respond_to? :find_index
      assert_equal(1,t.find_index {|i| i > 1})
    end
  end

  def test_first
    t = Triple.new(1,2,3)
    if t.respond_to? :first
      assert_equal(1,t.first)
    end
  end

  def test_flat_map
    t = Triple.new(1,2,3)
    if t.respond_to? :flat_map
      assert_equal([1,2,2,4,3,6],t.flat_map {|i| [i,i*2]})
    end
  end

  def test_grep
    t = Triple.new(1,2,3)
    if t.respond_to? :grep
      assert_equal([2,3], t.grep(2..3))
    end
  end

  def test_grep_block
    t = Triple.new(1,2,3)
    if t.respond_to? :all?
      assert_equal([2,3], t.grep(2..3) {|i| i})
    end
  end

  def test_grep_v
    t = Triple.new(1,2,3)
    if t.respond_to? :grap_v
      assert_equal([1], t.grep_v(2..3))
    end
  end

  def test_grep_v_block
    t = Triple.new(1,2,3)
    if t.respond_to? :all?
      assert_equal([1], t.grep_v(2..3) {|i| i})
    end
  end

  def test_group_by
    t = Triple.new(1,2,3)
    if t.respond_to? :group_by
      assert_equal({0=>[2], 1=>[1,3]}, t.group_by {|x| x%2})
    end
  end

  def test_include?
    t = Triple.new(1,2,3)
    if t.respond_to? :include?
      assert_equal(false,t.include?(33))
    end
  end

  def test_inject
    t = Triple.new(1,2,3)
    if t.respond_to? :inject
      assert_equal(6,t.inject(:+))
    end
  end

  def test_inject2
    t = Triple.new(1,2,3)
    if t.respond_to? :all?
      assert_equal(7,t.inject(1,:+))
    end
  end

  def test_inject3
    t = Triple.new(1,2,3)
    if t.respond_to? :inject
      assert_equal(6,t.inject {|sum,n| sum + n})
    end
  end

  def test_inject_block
    t = Triple.new(1,2,3)
    if t.respond_to? :inject
      assert_equal(7,t.inject(1) {|sum,n| sum + n})
    end
  end

  def test_map
    t = Triple.new(1,2,3)
    if t.respond_to? :map
      assert_equal([2,4,6],t.map {|x| x*2})
    end
  end

  def test_max
    t = Triple.new(1,2,3)
    if t.respond_to? :max
      assert_equal(3,t.max)
    end
  end

  def test_max_block
    t = Triple.new(1,4,6)
    if t.respond_to? :max
      assert_equal(1,t.max {|x| -x})
      assert_equal(6,t.max {|x| x})
    end
  end

  def test_max_a
    t = Triple.new(1,2,3)
    if t.respond_to? :max
      assert_equal([3,2],t.max(2))
    end
  end

  def test_max_ab_block
    t = Triple.new(1,2,3)
    if t.respond_to? :max
      assert_equal([3,2],t.max(2) {|x| -x})
    end
  end

  def test_max_by
    t = Triple.new(1,2,3)
    if t.respond_to? :max_by
      assert_equal(1,t.max_by {|x| -x})
    end
  end

  def test_max_by_n
    t = Triple.new(1,2,3)
    if t.respond_to? :max_by
    assert_equal([1,2],t.max_by(2) {|x| -x})
    end
  end

  def test_member?
    t = Triple.new(1,2,3)
    if t.respond_to? :member?
      assert_equal(true,t.member?(2))
      assert_equal(false,t.member?(33))
    end
  end

  def test_min
    t = Triple.new(1,2,3)
    if t.respond_to? :min
      assert_equal(1,t.min)
    end
  end

  def test_min_block
    t = Triple.new(1,2,3)
    if t.respond_to? :min
      assert_equal(3,t.min {|x| -x})
    end
  end

  def test_min_a
    t = Triple.new(1,2,3)
    if t.respond_to? :min
      assert_equal([1,2], t.min(2))
    end
  end

  def test_min_ab
    t = Triple.new(1,2,3)
    if t.respond_to? :min
      assert_equal([1,3],t.min(2) {|x| -x})
    end
  end

  def test_min_by_block
    t = Triple.new(1,2,3)
    if t.respond_to? :min
      assert_equal(3,t.min {|x| -x})
    end
  end

  def test_min_by_n
    t = Triple.new(1,2,3)
    if t.respond_to? :min_by
      assert_equal([3,2],t.min_by(2) {|x| -x})
    end
  end

  def test_minmax
    t = Triple.new(1,2,3)
    if t.respond_to? :minmax
      assert_equal([1,3], t.minmax)
    end
  end

  def test_minmax_ab
    t = Triple.new(1,2,3)
    if t.respond_to? :all?
      assert_equal([1,3], t.minmax {|a,b| a<=>b})
    end
  end

  def test_minmax_by
    t = Triple.new(1,2,3)
    if t.respond_to? :minmax_by
      assert_equal([3,1], t.minmax_by {|x| -x})
    end
  end

  def test_none?
    t = Triple.new(1,2,3)
    if t.respond_to? :none
      assert_equal(false,t.none? {|x| x**2==4})
      assert_equal(true, t.none? {|x| x**2 == 44})
    end
  end

  def test_one?
    t = Triple.new(1,2,3)
    if t.respond_to? :one?
      assert_equal(true,t.one? {|x| x**2==4})
      assert_equal(false, t.one? {|x| x**2 == 44})
    end
  end

  def test_partition
    t = Triple.new(1,2,3)
    if t.respond_to? :all?
      assert_equal([[2],[1,3]], t.partition { |x| x%2==0 })
    end
  end

  def test_reject
    t = Triple.new(1,2,3)
    if t.respond_to? :reject
      assert_equal([1,3],t.reject {|x| x==2})
    end
  end

  def test_reverse_each
    t = Triple.new(1,2,3)
    if t.respond_to? :reverse_each
      # becase to_a reverses as well, should put back to norm
      assert_equal([1,2,3], t.reverse_each {|x| p x}.to_a)
    end
  end

  def test_select
    t = Triple.new(1,2,3)
    if t.respond_to? :select
      assert_equal([2],t.select {|x| x==2})
    end
  end

  def test_slice_after
    t = Triple.new(1,2,3)
    if t.respond_to? :all?
      assert_equal([[1,2],[3]],t.slice_after(2).to_a)
    end
  end

  def test_slice_after_b
    t = Triple.new(1,2,3)
    if t.respond_to? :slice_after
      assert_equal([[1,2],[3]],t.slice_after {|x| x==2}.to_a)
    end
  end

  def test_slice_before
    t = Triple.new(1,2,3)
    if t.respond_to? :slice_before
      assert_equal([[1,2],[3]],t.slice_before(3).to_a)
    end
  end

  def test_before_b
    t = Triple.new(1,2,3)
    if t.respond_to? :slice_before
      assert_equal([[1,2],[3]],t.slice_before {|x| x==3}.to_a)
    end
  end

  def test_slice_when
    t = Triple.new(1,2,3)
    if t.respond_to? :slice_when
      assert_equal([[1,2],[3]],t.slice_when {|x| x==2}.to_a)
    end
  end

  def test_sort
    t = Triple.new(1,2,3)
    if t.respond_to? :sort
      assert_equal([1,2,3], t.sort)
    end
  end

  def test_sort_by
    t = Triple.new(1,2,3)
    if t.respond_to? :sort_by
      assert_equal([1,2,3], t.sort_by {|x| x})
    end
  end

  def test_sum
    t = Triple.new(1,2,3)
    if t.respond_to? :sum
      # not available in all versions of ruby
      assert_equal(6,t.sum)
    end
  end

  def test_sum_expr
    t = Triple.new(1,2,3)
    if t.respond_to? :sum
      assert_equal(12, t.sum {|x| x*2})
    end
  end

  def test_take
    t = Triple.new(1,2,3)
    if t.respond_to? :take
      assert_equal([1,2], t.take(2))
    end
  end

  def test_take_while
    t = Triple.new(1,2,3)
    if t.respond_to? :take_while
      assert_equal([1,2], t.take_while {|x| x <3})
    end
  end

  def test_to_a
    t = Triple.new(1,2,3)
    if t.respond_to? :to_a
      assert_equal([1,2,3], t.to_a)
    end
  end

  def test_to_h
    t = Triple.new(1,2,3)
    t = Triple.new([1,2],[3,4],[5,6])
    if t.respond_to? :to_h
      assert_equal({1=>2, 3=>4, 5=>6},t.to_h)
    end
  end

  def test_uniq
    t = Triple.new(1,2,3)
    if t.respond_to? :uniq
      assert_equal([1,2,3], t.uniq)
      assert_equal([1,2], Triple.new(1,1,2).uniq)
    end
  end

  def test_uniq_i
    t = Triple.new([1,2],[3,4],[5,6])
    if t.respond_to? :uniq
      assert_equal([[1,2],[3,4],[5,6]], t.uniq {|x| x})
      assert_equal([1,2], Triple.new(1,1,2).uniq {|x| x})
    end
  end

  def test_zip
    t = Triple.new(1,2,3)
    if t.respond_to? :zip
      assert_equal([[1,1],[2,2],[3,3]],t.zip(t))
    end
  end

  def test_zip_block
    t = Triple.new(1,2,3)
    if t.respond_to? :zip
      out = []
      t.zip(t) {|x,y| out << x*y}
      assert_equal(out,[1,4,9])
    end
  end
=end
  p 'A: Knock Knock'
  p 'B: Whose there?'
  p 'after a long delay....'
  p 'A: RUBY!'


end



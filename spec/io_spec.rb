# = NMatrix
#
# A linear algebra library for scientific computation in Ruby.
# NMatrix is part of SciRuby.
#
# NMatrix was originally inspired by and derived from NArray, by
# Masahiro Tanaka: http://narray.rubyforge.org
#
# == Copyright Information
#
# SciRuby is Copyright (c) 2010 - 2014, Ruby Science Foundation
# NMatrix is Copyright (c) 2012 - 2014, John Woods and the Ruby Science Foundation
#
# Please see LICENSE.txt for additional copyright notices.
#
# == Contributing
#
# By contributing source code to SciRuby, you agree to be bound by
# our Contributor Agreement:
#
# * https://github.com/SciRuby/sciruby/wiki/Contributor-Agreement
#
# == io_spec.rb
#
# Basic tests for NMatrix::IO.
#
require "tmpdir" # Used to avoid cluttering the repository.

require "./lib/nmatrix"

describe NMatrix::IO do
  before :each do
    @tmp_dir = Dir.mktmpdir
    @test_out = File.join(@tmp_dir, "test-out")
  end

  after :each do
    File.delete(@test_out) if File.file?(@test_out)
    Dir.rmdir(@tmp_dir)
  end

  it "repacks a string" do
    NMatrix::IO::Matlab.repack("hello", :miUINT8, :byte).should == "hello"
  end

  it "creates yale from internal byte-string function" do
    ia = NMatrix::IO::Matlab.repack("\0\1\3\3\4", :miUINT8, :itype)
    ja = NMatrix::IO::Matlab.repack("\0\1\3\0\0\0\0\0\0\0\0", :miUINT8, :itype)
    n = NMatrix.new(:yale, [4,4], :byte, ia, ja, "\2\3\5\4", :byte)
    n[0,0].should == 2
    n[1,1].should == 3
    n[1,3].should == 5
    n[3,0].should == 4
    n[2,2].should == 0
    n[3,3].should == 0
  end

  it "reads MATLAB .mat file containing a single square sparse matrix" do
    # Note: same matrix as above
    n = NMatrix::IO::Matlab.load_mat("spec/4x4_sparse.mat")
    n[0,0].should == 2
    n[1,1].should == 3
    n[1,3].should == 5
    n[3,0].should == 4
    n[2,2].should == 0
    n[3,3].should == 0
  end

  it "reads MATLAB .mat file containing a single dense integer matrix" do
    n = NMatrix::IO::Matlab.load_mat("spec/4x5_dense.mat")
    m = NMatrix.new([4,5], [16,17,18,19,20,15,14,13,12,11,6,7,8,9,10,5,4,3,2,1])
    n.should == m
  end

  it "reads MATLAB .mat file containing a single dense double matrix" do
    n = NMatrix::IO::Matlab.load_mat("spec/2x2_dense_double.mat")
    m = NMatrix.new(2, [1.1, 2.0, 3.0, 4.0], dtype: :float64)
    n.should == m
  end

  it "loads and saves MatrixMarket .mtx file containing a single large sparse double matrix" do
    pending "spec disabled because it's so slow"
    n = NMatrix::IO::Market.load("spec/utm5940.mtx")
    NMatrix::IO::Market.save(n, "spec/utm5940.saved.mtx")
    `wc -l spec/utm5940.mtx`.split[0].should == `wc -l spec/utm5940.saved.mtx`.split[0]
  end

  it "raises an error when reading a non-existent file" do
    fn = rand(10000000).to_i.to_s
    while File.exist?(fn)
      fn = rand(10000000).to_i.to_s
    end
    expect{ NMatrix.read(fn) }.to raise_error(Errno::ENOENT)
  end

  it "reads and writes NMatrix dense" do
    n = NMatrix.new(:dense, [4,3], [0,1,2,3,4,5,6,7,8,9,10,11], :int32)
    n.write(@test_out)

    m = NMatrix.read(@test_out)
    n.should == m
  end

  it "reads and writes NMatrix dense as symmetric" do
    n = NMatrix.new(:dense, 3, [0,1,2,1,3,4,2,4,5], :int16)
    n.write(@test_out, :symmetric)

    m = NMatrix.read(@test_out)
    n.should == m
  end

  it "reads and writes NMatrix dense as skew" do
    n = NMatrix.new(:dense, 3, [0,1,2,-1,3,4,-2,-4,5], :float64)
    n.write(@test_out, :skew)

    m = NMatrix.read(@test_out)
    n.should == m
  end

  it "reads and writes NMatrix dense as hermitian" do
    n = NMatrix.new(:dense, 3, [0,1,2,1,3,4,2,4,5], :complex64)
    n.write(@test_out, :hermitian)

    m = NMatrix.read(@test_out)
    n.should == m
  end

  it "reads and writes NMatrix dense as upper" do
    n = NMatrix.new(:dense, 3, [-1,1,2,3,4,5,6,7,8], :int32)
    n.write(@test_out, :upper)

    m = NMatrix.new(:dense, 3, [-1,1,2,0,4,5,0,0,8], :int32) # lower version of the same

    o = NMatrix.read(@test_out)
    o.should == m
    o.should_not == n
  end

  it "reads and writes NMatrix dense as lower" do
    n = NMatrix.new(:dense, 3, [-1,1,2,3,4,5,6,7,8], :int32)
    n.write(@test_out, :lower)

    m = NMatrix.new(:dense, 3, [-1,0,0,3,4,0,6,7,8], :int32) # lower version of the same

    o = NMatrix.read(@test_out)
    o.should == m
    o.should_not == n
  end
end

require 'spec_helper'

describe RubyCA::Index::FileIndex do
  before do
    @example_ca = File.dirname(__FILE__) + "/../../../example_ca"
    @index = RubyCA::Index::FileIndex.new('database' => @example_ca + "/index.txt")
  end


  describe "certificate list" do
    it "should list all certificates" do
      File.readable?(@index.database).should be_true

      certs = @index.certificates
      certs.count.should eql(2)
    end

    it "should filter by serial" do
      certs = @index.certificates_by_serial("02")
      certs.count.should eql(1)
      certs[0].serial.should eql("02")
    end

    it "should filter by organization" do
      certs = @index.certificates_by_organization("Examplicon Ltd.")
      certs.count.should eql(2)
      certs[0].serial.should eql("01")
      certs[0].cn.should eql("ceo_notebook.example.com")
      certs[1].serial.should eql("02")
    end
  end

  describe "saving" do
    it "should save" do
      pending "Test the index save!"
    end
  end
end
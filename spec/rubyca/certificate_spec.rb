require 'spec_helper'

describe RubyCA::Certificate do
  before do
    @cert = RubyCA::Certificate.new({
      :serial => "02",
      :dn => "/C=DE/ST=Berlin/L=Berlin/O=Examplicon Ltd./OU=Stuffers/CN=clerk_desktop.example.com/name=Johnny Clerk/emailAddress=clerk@example.com",
    })
  end

  describe 'Status' do
    it "should have the default status 'Valid'" do
      @cert.status.should eql(RubyCA::Certificate::STATUS[:valid])
      @cert.valid?.should be_true
    end

    it "should expire when expire date is in the past" do
      @cert.valid?.should be_true
      @cert.expire_date = DateTime.now - 2

      @cert.status.should eql(RubyCA::Certificate::STATUS[:expired])
      @cert.expired?.should be_true

      @cert.expire_date = nil
      @cert.expired?.should be_false
      @cert.valid?.should be_true
    end

    it "should not expire when expire date is in the future" do
      @cert.valid?.should be_true

      @cert.expire_date = DateTime.now + 2
      @cert.expired?.should be_false
      @cert.valid?.should be_true
    end

    it "should be revoked when revoke date is in the past" do
      @cert.valid?.should be_true
      @cert.revoke_date = DateTime.now - 2

      @cert.status.should eql(RubyCA::Certificate::STATUS[:revoked])
      @cert.revoked?.should be_true

      @cert.revoke_date = nil
      @cert.revoked?.should be_false
      @cert.valid?.should be_true
    end

    it "should not be revoked when revoke_date is in the future" do
      @cert.valid?.should be_true

      @cert.revoke_date = DateTime.now + 2
      @cert.revoked?.should be_false
      @cert.valid?.should be_true
    end

    it "should handle revoked status at higer priority than expired" do
      @cert.valid?.should be_true

      @cert.expire_date = DateTime.now - 2
      @cert.expired?.should be_true

      @cert.revoke_date = DateTime.now - 2
      @cert.revoked?.should be_true

      @cert.expire_date = nil
      @cert.revoked?.should be_true

      @cert.revoke_date = nil
      @cert.valid?.should be_true

      @cert.revoke_date = DateTime.now - 1
      @cert.expire_date = DateTime.now - 2
      @cert.revoked?.should be_true
      @cert.revoke_date = nil
      @cert.expired?.should be_true
    end
  end

  describe 'DN' do
    it "should parse the DN" do
      @cert.dn.is_a?(Hash).should be_true

      @cert.dn['CN'].should == "clerk_desktop.example.com"
      @cert.dn['CN'].should eql(@cert.cn)

      @cert.country.should == "DE"
      @cert.email.should == "clerk@example.com"
      @cert.location.should == "Berlin"
      @cert.name.should == "Johnny Clerk"
      @cert.state.should == "Berlin"
      @cert.organization.should == "Examplicon Ltd."
      @cert.ou.should == "Stuffers"
    end
  end
end

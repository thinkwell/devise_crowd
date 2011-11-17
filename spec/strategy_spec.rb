require 'spec_helper'

module Devise::Strategies

  describe CrowdAuthenticatable do

    # TODO: This should not be needed.  This throws an exception including
    # Rails.application.routes.url_helpers the first time it is called.
    before(:all) do
      Devise.add_mapping(:mock_users, :class_name => Devise::Mock::User) rescue nil
    end

    before(:each) do
      Devise.add_mapping(:mock_users, :class_name => Devise::Mock::User)
      @model = Devise::Mock::User.new(:id => 555)
      stub(Devise::Mock::User).find_for_authentication({:id => '555'}){@model}
    end

    def strategy(uri, cookies={})
      CrowdAuthenticatable.new(Rack::MockRequest.env_for(uri, 'HTTP_COOKIE'=>cookies.to_query), :mock_user)
    end

    context "with a crowd token cookie" do
      before(:each) do
        @strategy = strategy("http://example.com/foobar", 'crowd.token_key' => 555)
      end

      it "is valid for crowd authentication" do
        @strategy.should be_valid
      end
    end

    context "with a crowd token param" do
      before(:each) do
        @strategy = strategy("http://example.com/foobar?crowd.token_key=555")
      end

      it "is valid for crowd authentication" do
        @strategy.should be_valid
      end
    end

    context "with no crowd token" do
      before(:each) do
        @strategy = strategy("http://example.com/foobar")
      end

      it "is not valid for checking authentication" do
        @strategy.should_not be_valid
      end
    end

  end
end

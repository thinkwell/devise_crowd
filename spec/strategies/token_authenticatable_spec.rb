require 'spec_helper'

module Devise::Strategies

  describe CrowdTokenAuthenticatable do

    def crowd_username; 'gcostanza'; end
    def crowd_token; '1234567890abcdefghijklmno'; end

    # TODO: This should not be needed.  This throws an exception including
    # Rails.application.routes.url_helpers the first time it is called.
    before(:all) do
      Devise.add_mapping(:mock_users, :class_name => Devise::Mock::User) rescue nil
    end

    before(:each) do
      Devise.add_mapping(:mock_users, :class_name => Devise::Mock::User)
      @model = Devise::Mock::User.new(:id => 555)
    end

    def strategy(uri, cookies={})
      env = Rack::MockRequest.env_for(uri, 'HTTP_COOKIE'=>cookies.to_query)
      env['warden'] = warden_manager
      CrowdTokenAuthenticatable.new(env, :mock_user)
    end

    context "with a crowd token cookie" do
      before(:each) do
        @strategy = strategy("http://example.com/foobar", 'crowd.token_key' => crowd_token)
      end

      it "is valid for crowd authentication" do
        @strategy.should be_valid
      end

      it "authenticates the crowd token" do
        mock(@mock_crowd_client).is_valid_user_token?(crowd_token) {true}
        mock(@mock_crowd_client).find_username_by_token(crowd_token) {crowd_username}
        mock(Devise::Mock::User).find_for_authentication({'crowd_username' => crowd_username}){@model}
        #mock.proxy(@strategy).success!(@model)
        @strategy.authenticate!
        @strategy.result.should == :success
      end

      it "rejects an invalid crowd token" do
        mock(@mock_crowd_client).is_valid_user_token?(crowd_token) {false}
        @strategy.authenticate!
        @strategy.result.should == :failure
      end

      it "rejects an unknown crowd username" do
        mock(@mock_crowd_client).is_valid_user_token?(crowd_token) {true}
        mock(@mock_crowd_client).find_username_by_token(crowd_token) {'foobar'}
        mock(Devise::Mock::User).find_for_authentication({'crowd_username' => 'foobar'}){nil}
        @strategy.authenticate!
        @strategy.result.should == :failure
      end
    end

    context "with a crowd token param" do
      before(:each) do
        @strategy = strategy("http://example.com/foobar?crowd.token_key=#{crowd_token}")
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

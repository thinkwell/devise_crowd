require 'spec_helper'

module Devise::Models
  describe CrowdCommon do


    before(:each) do
      @model_class = Devise::Mock::User
      @model = @model_class.new
    end


    it "adds config methods to model class" do
      @model_class.should respond_to('crowd_enabled')
      @model_class.should respond_to('crowd_service_url')
      @model_class.should respond_to('crowd_app_name')
      @model_class.should respond_to('crowd_app_password')
      @model_class.should respond_to('crowd_token_key')
      @model_class.should respond_to('crowd_username_key')
      @model_class.should respond_to('crowd_auth_every')
      @model_class.should respond_to('crowd_allow_forgery_protection')
    end


    it "adds class methods to model class" do
      @model_class.should respond_to('crowd_enabled?')
      @model_class.should respond_to('find_for_crowd_username')
    end

    it "adds instance methods to model" do
      @model.should respond_to('needs_crowd_auth?')
      @model.should respond_to('after_crowd_authentication')
    end

    it "adds callback methods" do
      @model_class.should respond_to('before_create_from_crowd')
      @model_class.should respond_to('after_create_from_crowd')
      @model_class.should respond_to('around_create_from_crowd')
      @model_class.should respond_to('before_sync_from_crowd')
      @model_class.should respond_to('after_sync_from_crowd')
      @model_class.should respond_to('around_sync_from_crowd')
    end

    describe 'crowd_enabled?' do
      it "returns true when strategy is in an array of strategies" do
        stub(Devise).crowd_enabled{[:crowd, :foo_bar]}
        @model_class.should be_crowd_enabled(:crowd)
      end

      it "returns true for a globally true configuration" do
        stub(Devise).crowd_enabled{true}
        @model_class.should be_crowd_enabled(:crowd)
      end

      it "returns true for a globally false configuration" do
        stub(Devise).crowd_enabled{false}
        @model_class.should_not be_crowd_enabled(:crowd)
      end
    end

    describe '#crowd_username_key' do
      it "returns the key set in config" do
        mock(Devise).crowd_username_key.at_least(1) {:foobar}
        @model_class.crowd_username_key.should == :foobar
      end

      it "returns the first authentication_keys key if no config is set" do
        mock(Devise).crowd_username_key.at_least(1) {nil}
        mock(Devise).authentication_keys.at_least(1) {[:foo, :bar]}
        @model_class.crowd_username_key.should == :foo
      end
    end

    describe '#create_from_crowd' do
      it "calls do_create_from_crowd" do
        mock(@model).do_create_from_crowd
        @model.create_from_crowd
      end

      it "calls sync_from_crowd by default" do
        mock(@model).sync_from_crowd
        @model.create_from_crowd
      end

      it "runs callbacks" do
        mock(@model).run_callbacks(:create_from_crowd) {false}
        @model.create_from_crowd.should == false
      end

      it "terminates if :before callback returns false" do
        mock(@model).allow_create_from_crowd? {false}
        dont_allow(@model).do_create_from_crowd
        @model.create_from_crowd
      end
    end

    describe '#sync_from_crowd' do
      it "calls do_sync_from_crowd" do
        mock(@model).do_sync_from_crowd
        @model.sync_from_crowd
      end

      it "runs callbacks" do
        mock(@model).run_callbacks(:sync_from_crowd) {false}
        @model.sync_from_crowd.should == false
      end

      it "terminates if :before callback returns false" do
        mock(@model).allow_sync_from_crowd? {false}
        dont_allow(@model).do_sync_from_crowd
        @model.sync_from_crowd
      end
    end

  end
end

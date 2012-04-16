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
      @model_class.should respond_to('crowd_username_field')
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

  end
end

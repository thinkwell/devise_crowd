require 'spec_helper'

module Devise::Models
  describe CrowdCredentialsAuthenticatable do

    before(:each) do
      @model_class = Devise::Mock::User
      @model = @model_class.new
    end

    it "adds instance methods to the model" do
      @model.should respond_to('after_crowd_credentials_authentication')
      @model.should respond_to('password=')
    end
  end
end

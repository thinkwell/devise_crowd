require 'spec_helper'

module Devise::Models
  describe CrowdTokenAuthenticatable do

    before(:each) do
      @model_class = Devise::Mock::User
      @model = @model_class.new
    end

    it "adds config methods to model class" do
      @model_class.should respond_to('crowd_token_cookie')
      @model_class.should respond_to('crowd_token_param')
    end
  end
end

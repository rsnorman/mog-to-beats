class ApplicationController < ActionController::Base
  protect_from_forgery

  def mog_username
  	request.env["HTTP_MOG_USER_NAME"]
  end

  def beats_username
  	request.env["HTTP_BEATS_USER_NAME"]
  end
end

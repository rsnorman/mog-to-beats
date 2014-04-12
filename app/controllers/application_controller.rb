class ApplicationController < ActionController::Base
  protect_from_forgery

  def mogid
  	request.env["HTTP_MOG_ID"]
  end

  def beats_auth_token
  	request.env["HTTP_BEATS_AUTH_TOKEN"]
  end

  def beats_user_id
  	request.env["HTTP_BEATS_USER_ID"]
  end
end

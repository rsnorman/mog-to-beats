module AuthHelper  
  def auth_parameters(username = 'rsnorman15@gmail.com')
    {'HTTP_MOG_USER_NAME' => username, 'HTTP_BEATS_USER_NAME' => username}
  end
end
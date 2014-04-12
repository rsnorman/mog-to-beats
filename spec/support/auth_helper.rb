module AuthHelper  
  def auth_parameters(mogid = "V3.PpcEwuNWs6emXNGOz2GLsr27FdV3X3eiykcVmJtzBNZAQ-ArAydsPWN5p6-zcRFL", beats_user_id = '139591750279758080',  beats_auth_token = "Mg%3D%3D%246%2FJhhYwCEf%2BhGKR7GGiiDe1%2BFLGQI%2BwIiT6ZwZBdIEkj398CFPnrx09AAOfs1jw6CSFaQFljRNIt9xcom%2B%2FXwg1PUi%2FuWrFEQiMmIyvcmwL4v%2BoFmE%2FV5YqINtY6xpC9Ch%2F72IIgOcSF1iO1qMRMcg%3D%3D")
    {'HTTP_MOG_ID' => mogid, 'HTTP_BEATS_USER_ID' => beats_user_id, 'HTTP_BEATS_AUTH_TOKEN' => beats_auth_token}
  end
end
class User < ActiveRecord::Base
  act_as_i_am_i_can strict_mode: true
end

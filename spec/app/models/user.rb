class User < ActiveRecord::Base
  act_as_i_am_i_can strict_mode: true

  def load_roles_from_database
    nil
  end
end

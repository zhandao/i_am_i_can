class User
  extend IAmICan
  act_as_i_am_i_can

  def load_roles_from_database
    nil
  end
end

class Hash
  alias names keys
end

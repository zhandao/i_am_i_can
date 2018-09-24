class UserRoleGroup < ActiveRecord::Base
  def members
    UserRole.where(id: member_ids)
  end
end

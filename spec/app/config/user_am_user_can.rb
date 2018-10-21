IAmICan::Configs.set_for(subject: 'User',
                         role: 'UserRole',
                         permission: 'UserPermission',
                         role_group: 'UserRoleGroup') do |config|
  config.strict_mode = true
end

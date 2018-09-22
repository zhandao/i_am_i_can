RSpec.describe IAmICan::Permission::Owner do
  subject { UserRole }
  let(:roles) { subject }
  let(:role) { roles.create(name: :admin) }
  let(:role_groups) { UserRoleGroup }
  let(:role_group) { role_groups.create(name: :vip) }
  let(:permission_records) { UserPermission }

  describe '.has_permission' do
    before { roles.has_permission :manage_users }
    it { expect(:manage_users).to be_in roles.stored_permission_names }
    it { expect(:manage_users).not_to be_in roles.local_permissions.keys }
    it { expect(permission_records.count).to eq(1) }
  end

  describe '#can' do
    before { role.can :manage_users }

    context 'when giving permission name is not defined' do
      before { role.can :do_something }
    end
  end
end

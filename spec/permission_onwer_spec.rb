RSpec.describe IAmICan::Permission::Owner do
  subject { UserRole }
  let(:roles) { subject }
  let(:role) { roles.create(name: :admin) }
  let(:role_groups) { UserRoleGroup }
  let(:role_group) { role_groups.create(name: :vip) }
  let(:permission_records) { UserPermission }
  let(:user) { User.create(id: 1) }

  describe '.has_permission & .declare_permission' do
    context '.has_permission (save by default)' do
      before { roles.has_permission :manage, obj: User }
      it { expect(:manage_User).to be_in roles.stored_permission_names }
      it { expect(:manage_User).not_to be_in roles.local_permissions.keys }
      it { expect(permission_records.last).to have_attributes(pred: 'manage', obj_type: 'User', obj_id: nil) }
    end

    context '.declare_permission (not save)' do
      before { roles.declare_permission :manage, obj: user }
      it do
        expect(:manage_User_1).not_to be_in roles.stored_permission_names
        expect(:manage_User_1).to be_in roles.local_permissions.keys
      end
    end
  end

  describe '#can (save case)' do
    before { roles.has_permission :manage, obj: User }

    context 'when giving pred is defined' do
      context 'and obj is defined' do
        before { role.can :manage, obj: User }

        it 'assigns the permissions which are matched by the pred and obj' do
          expect(:manage_User).not_to be_in(role.local_permission_names)
          expect(:manage_User).to be_in(role.stored_permission_names)
        end
      end

      context 'but obj is not given' do
        # TODO: is reasonable?
        it 'assigns all the permissions which are matched by the pred to the role' do
          expect{ role.can :manage }.not_to raise_error
          expect(:manage_User).to be_in(role.stored_permission_names)
        end
      end

      context 'but obj is not defined' do
        it { expect{ role.can :manage, obj: :user }.to raise_error(IAmICan::Error) }
      end
    end

    context 'when giving pred is not defined' do
      it { expect{ role.can :fly }.to raise_error(IAmICan::Error) }
    end
  end

  describe '#temporarily_can (not save)' do
    #
  end
end

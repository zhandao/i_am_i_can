RSpec.describe IAmICan::Permission::Owner do
  subject { UserRole }
  let(:roles) { subject }
  let(:role) { roles.create(name: :admin) }
  let(:permission_records) { UserPermission }
  let(:user) { User.create(id: 1) }

  describe '.has_permission & .declare_permission' do
    context '.has_permission (save by default)' do
      before { roles.has_permission :manage, obj: User }
      it { expect(:manage_User).to be_in roles.stored_permission_names }
      it { expect(:manage_User).not_to be_in roles.local_permissions.keys }
      it { expect(permission_records.last).to have_attributes(pred: 'manage', obj_type: 'User', obj_id: nil) }

      context 'when giving multi preds' do
        context 'without obj' do
          before { roles.has_permissions :fly, :run, :jump }
          it { expect(roles.stored_permission_names).to contain(%i[fly run jump])}
          it { expect(permission_records.count).to eq(1+3) }
        end

        context 'with obj' do
          before { roles.has_permissions *%i[read write copy remove], obj: File }
          it { expect(roles.stored_permission_names).to contain(%i[read_File write_File copy_File remove_File])}
          it { expect(permission_records.count).to eq(1+4) }
        end
      end
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
        it { expect{ role.can :manage, obj: :user }
                 .to raise_error(IAmICan::Error).with_message(/\[:manage_user\] have not been defined/) }
      end

      context 'but obj is been covered' do
        before { roles.has_permission :manage, obj: user }

        before { role.can :manage, obj: User }
        it { expect{ role.can :manage, obj: user }
                 .to raise_error(IAmICan::Error).with_message(/\[:manage_User_1\] have been covered/) }
      end
    end

    context 'when giving pred is not defined' do
      it { expect{ role.can :fly }
               .to raise_error(IAmICan::Error).with_message(/\[:fly\] have not been defined/) }
    end
  end

  describe '#temporarily_can (not save)' do
    # like above
  end

  describe '#can?' do
    before { roles.has_permission :fly }
    before { role.can :fly }
    before { roles.has_permission :manage, obj: User }
    before { role.can :manage, obj: User }

    context 'when querying by correct pred' do
      it { expect(role.can? :fly).to be_truthy }
      it { expect(role.can? :manage, User).to be_truthy }

      context 'when querying matched' do
        it { expect(role.can? :fly, obj: :sky).to be_truthy }
        it { expect(role.can? :manage, user).to be_truthy }
        it { expect(role.can? :manage).to be_falsey }
        it { expect(role.can? :manage, :someone_else).to be_falsey }

        before { roles.has_permission :lead, obj: User.create(id: 2) }
        before { role.can :lead, obj: User.find(2) }
        it do
          expect(role.can? :lead).to be_falsey
          expect(role.can? :lead, User).to be_falsey
          expect(role.can? :lead, User.find(2)).to be_truthy
          expect(role.can? :lead, User.create(id: 3)).to be_falsey
        end
      end
    end

    context 'when querying by not defined perd' do
      it { expect(role.can? :xpred).to be_falsey }
    end
  end
end

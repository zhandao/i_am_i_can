RSpec.describe IAmICan::Permission::Assignment do
  subject { UserRole }
  let(:roles) { subject }
  let(:role) { roles.create(name: :admin) }
  let(:permission_records) { UserPermission }
  let(:user) { User.create(id: 1) }

  cls_cleaning

  describe '#can (save case)' do
    before { roles.has_permission :manage, obj: User }

    context 'when giving action is defined' do
      context 'and obj is defined' do
        before { role.can :manage, obj: User }

        it 'assigns the permissions which are matched by the action and obj' do
          expect(:manage_User).to be_in(role._permissions.names)
        end
      end

      context 'but obj is not given' do
        # TODO: is reasonable?
        it 'assigns all the permissions which are matched by the action to the role' do
          expect{ role.can :manage }
              .to raise_error(IAmICan::Error).with_message(/\[:manage\] have not been defined/)
        end
      end

      context 'but obj is not defined' do
        it { expect{ role.can :manage, obj: :user }
                 .to raise_error(IAmICan::Error).with_message(/\[:manage_user\] have not been defined/) }
      end
    end

    context 'when giving action is not defined' do
      it { expect{ role.can :fly }
               .to raise_error(IAmICan::Error).with_message(/\[:fly\] have not been defined/) }
    end
  end

  describe '#temporarily_can (not save)' do
    # like above
  end

  describe 'role#can?' do
    before { roles.has_permission :fly }
    before { role.can :fly }
    before { roles.has_permission :manage, obj: User }
    before { role.can :manage, obj: User }

    context 'when querying by correct action' do
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
      it { expect(role.can? :xaction).to be_falsey }
    end
  end

  describe 'role#cannot' do
    before { roles.have_permissions :talk_to, obj: user }
    before { role.can :talk_to, obj: user }

    it do
      expect(role.can? :talk_to, user).to be_truthy
      expect{ role.cannot :talk_to, obj: user }.not_to raise_error
      expect{ role.cannot :talk_to, obj: User.create(id: 2) }
          .to raise_error(IAmICan::Error).with_message(/\[:talk_to_User_2\] have not been defined/)
      expect(role.can? :talk_to, user).to be_falsey
    end
  end

  describe '#can_only' do
    before { roles.have_permissions :create, :update, :destroy, obj: user }
    before { role.can :create, obj: user }

    it do
      expect(role.can? :create, user).to be_truthy
      expect{ role.can_only :update, :destroy, obj: user }.to change(role._permissions, :count).by 1
      expect(role.can? :create, user).to be_falsey
      expect(role.can? :update, user).to be_truthy
      expect(role.can? :destroy, user).to be_truthy
    end
  end
end

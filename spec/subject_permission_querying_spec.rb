RSpec.describe IAmICan::Subject::PermissionQuerying do
  let(:people) { User }
  subject { User.create }
  let(:he) { subject }
  let(:his) { subject }

  describe '#can? & #can!' do
    context 'temporarily_can?' do
      before { he.temporarily_is :magician, which_can: [:perform], obj: :magic }

      it do
        expect(he.can? :perform, :magic).to be_truthy
        expect(he.can? :perform).to be_falsey
        expect(he.can? :perform, :something_else).to be_falsey
      end
    end

    context 'stored_can?' do
      before do
        he.becomes_a :coder, which_can: :fly
        he.becomes_a :admin, which_can: :manage, obj: User
        UserRole.have_permissions :sing
        # pp '====================='
      end

      it { expect(he.can? :sing).to be_falsey }
      it { expect(he.can? :fly).to be_truthy }
      it { expect(he.can? :fly, :everywhere).to be_truthy }
      it { expect(he.can? :manage, User).to be_truthy }
      it { expect(he.can? :manage, he).to be_truthy }
      it { expect(he.can? :manage).to be_falsey }
      it { expect(he.can? :manage, :everyone).to be_falsey }
    end

    context 'group_can?' do
      before do
        people.have_and_group_roles :admin, :master, by_name: :manager
        UserRoleGroup.have_permission :manage, obj: :system
        UserRoleGroup.which(name: :manager).can :manage, obj: :system
        he.becomes_a :admin
      end

      it { expect(he.can? :manage, :system).to be_truthy }
      it { expect(he.can? :manage).to be_falsey }
      it { expect(he.can? :manage, :something_else).to be_falsey }
    end
  end

  describe '#can_each? & #can_each!' do
  end
end

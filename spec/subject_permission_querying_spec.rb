RSpec.describe IAmICan::Subject::PermissionQuerying do
  let(:people) { User }
  subject { User.create }
  let(:he) { subject }
  let(:his) { subject }

  before do
    he.becomes_a :coder, which_can: :fly
    he.becomes_a :admin, which_can: :manage, obj: User
    UserRole.have_permissions :sing
  end

  describe '#can? & #can!' do
    context 'stored case' do
      it { expect(he.can? :sing).to be_falsey }
      it { expect(he.can? :fly).to be_truthy }
      it { expect(he.can? :fly, :everywhere).to be_truthy }
      it { expect(he.can? :manage, User).to be_truthy }
      it { expect(he.can? :manage, he).to be_truthy }
      it { expect(he.can? :manage).to be_falsey }
      it { expect(he.can? :manage, :everyone).to be_falsey }
    end
  end

  describe '#can_each? & #can_each!' do
    it { expect(he.can? :fly).to be_truthy }
  end
end

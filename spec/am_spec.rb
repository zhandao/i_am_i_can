RSpec.describe IAmICan::Am do
  subject { User.new }
  let(:he) { subject }
  let(:his) { subject }

  before do
    User.has_role :admin, :master, :guest
  end

  describe '#is' do
    before { he.is :admin }
    it { expect(:admin).to be_in(his.roles) }

    context 'when giving a role which is not defined' do
      it { expect{ he.is :someone }.to raise_error(IAmICan::Error)  }
    end

    context 'when giving multi roles' do
      before { he.is :master, :guest }
      it { expect(User.roles.names).to contain(%i[master guest]) }
    end

    context 'when assigning the role which is assigned before' do
      before { he.is :admin }
      it { expect(:admin).to be_in(his.roles) }
    end
  end

  describe '#is? & #isnt? & is!' do
    before { he.is :admin }
    it { expect(he.is? :admin).to be_truthy }
    it { expect(he.isnt? :admin).to be_falsey }
    it { expect(he.is! :admin).to be_truthy }
    it { expect{ he.is! :someone }.to raise_error(IAmICan::VerificationFailed) }
  end

  describe '#is_every? & #is_every!' do
    before { he.is :admin, :master }
    it { expect(he.is_every? :admin, :master).to be_truthy }
    it { expect(he.is_every? :admin, :guest).to be_falsey }
    it { expect(he.is_every! :master, :admin).to be_truthy }
    it { expect{ he.is_every! :guest, :admin }.to raise_error(IAmICan::VerificationFailed) }
  end
end

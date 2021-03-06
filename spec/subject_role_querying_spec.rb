RSpec.describe IAmICan::Subject::RoleQuerying do
  let(:people) { User }
  let(:people) { User }
  subject { User.create }
  let(:he) { subject }
  let(:his) { subject }

  cls_cleaning

  before do
    people.have_role :admin, :master, :guest, :dev
  end

  describe '#is? & #isnt? & is!' do
    before { he.becomes_a :admin }
    it { expect(he.is? :admin).to be_truthy }
    it { expect(he.isnt? :admin).to be_falsey }
    it { expect(he.is! :admin).to be_truthy }
    it { expect{ he.is! :someone }.to raise_error(IAmICan::VerificationFailed) }
  end

  describe 'for testing role assignment with expire time' do
    context 'when giving :expires_at' do
      before { he.is_a :admin, expires_at: 1.years.after }
      it { expect(he.is? :admin).to be_truthy }

      before { he.is_a :master, expires_at: 1.years.ago }
      it { expect(people.first.is? :master).to be_falsey }
    end

    context 'when giving :expires_in' do
      before { he.is_a :admin, expires_in: 1.years }
      it { expect(he.is? :admin).to be_truthy }
    end
  end

  describe '#is_one_of? #is_one_of!' do
    # TODO
  end

  describe '#is_every? & #is_every!' do
    before { he.becomes_a :admin, :master }
    it { expect(he.is_every? :admin, :master).to be_truthy }
    it { expect(he.is_every? :admin, :guest).to be_falsey }
    it { expect(he.is_every! :master, :admin).to be_truthy }
    it { expect{ he.is_every! :guest, :admin }.to raise_error(IAmICan::VerificationFailed) }
  end

  describe '#is_in_role_group?' do # TODO ! & in one of group
    before { people.have_and_group_roles :vip1, :vip2, :vip3, by_name: :vip }
    before { people.have_and_group_roles :a, :b, :c, by_name: :abc }
    before { he.becomes_a :vip1 }
    it { expect(he.is_in_role_group? :vip).to be_truthy }
    it { expect(he.is_in_role_group? :abc).to be_falsey }
  end
end

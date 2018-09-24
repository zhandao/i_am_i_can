RSpec.describe IAmICan::Subject::RoleQuerying do
  let(:people) { User }
  let(:people) { User }
  subject { User.create }
  let(:he) { subject }
  let(:his) { subject }

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

  describe '#is_every? & #is_every!' do
    before { he.becomes_a :admin, :master }
    it { expect(he.is_every? :admin, :master).to be_truthy }
    it { expect(he.is_every? :admin, :guest).to be_falsey }
    it { expect(he.is_every! :master, :admin).to be_truthy }
    it { expect{ he.is_every! :guest, :admin }.to raise_error(IAmICan::VerificationFailed) }
  end

  describe '#is_in_role_group?' do
    before { people.have_and_group_roles :vip1, :vip2, :vip3, by_name: :vip }
    before { people.have_and_group_roles :a, :b, :c, by_name: :abc }
    before { he.becomes_a :vip1 }
    it { expect(he.is_in_role_group? :vip).to be_truthy }
    it { expect(he.is_in_role_group? :abc).to be_falsey }
  end
end

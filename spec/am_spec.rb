RSpec.describe IAmICan::Am do
  subject { User.create }
  let(:they) { User }
  let(:their) { User }
  let(:their_role_model) { UserRole }
  let(:he) { subject }
  let(:his) { subject }

  before do
    they.has_role :admin, :master, :guest
  end

  describe '#becomes_a' do
    before { he.becomes_a :admin }
    it { expect(:admin).to be_in(his.local_roles) }

    context 'when giving a role which is not defined' do
      it { expect{ he.becomes_a :someone_else }.to raise_error(IAmICan::Error)  }
    end

    context 'when giving multi roles' do
      before { he.becomes_a :master, :guest }
      it { expect(their.local_roles.names).to contain(%i[master guest]) }
    end

    context 'when assigning the role which is assigned before' do
      before { he.becomes_a :admin }
      it { expect(:admin).to be_in(his.local_roles) }
    end

    context 'save' do
      context 'when the role definition is not stored' do
        it { expect{ he.store_role :master }.to raise_error(IAmICan::Error) }
      end

      context 'correct' do
        before { they.store_role :dev }
        it do
          expect(his.role_ids).to be_empty
          expect{ he.store_role :dev }.not_to raise_error
          expect(:dev).to be_in(his.local_roles)
          expect(his.role_ids).to have_size(1)
        end
      end
    end
  end

  describe '#is? & #isnt? & is!' do
    before { he.is_roles :admin }
    it { expect(he.is? :admin).to be_truthy }
    it { expect(he.isnt? :admin).to be_falsey }
    it { expect(he.is! :admin).to be_truthy }
    it { expect{ he.is! :someone }.to raise_error(IAmICan::VerificationFailed) }
  end

  describe '#is_every? & #is_every!' do
    before { he.is_roles :admin, :master }
    it { expect(he.is_every? :admin, :master).to be_truthy }
    it { expect(he.is_every? :admin, :guest).to be_falsey }
    it { expect(he.is_every! :master, :admin).to be_truthy }
    it { expect{ he.is_every! :guest, :admin }.to raise_error(IAmICan::VerificationFailed) }
  end

  # TODO: 测试数据库变化时的情况
  describe '#is_in_role_group?' do
    before { User.has_and_group_roles :vip1, :vip2, :vip3, by_name: :vip }
    before { User.has_and_group_roles :a, :b, :c, by_name: :abc }
    before { he.is_roles :vip1 }
    it { expect(he.is_in_role_group? :vip).to be_truthy }
    it { expect(he.is_in_role_group? :abc).to be_falsey }
  end
end

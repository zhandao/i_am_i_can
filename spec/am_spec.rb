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

  describe '#becomes_a & #is_temporarily' do
    context 'when using #becomes_a' do
      before { he.becomes_a :admin }
      it { expect(:admin).to be_in(his.stored_role_names) }
      it { expect(:admin).not_to be_in(his.local_role_names) }
    end

    context 'when using #is_temporarily' do
      before { he.is_temporarily :admin }
      it { expect(:admin).to be_in(his.local_role_names) }
      it { expect(:admin).not_to be_in(his.stored_role_names) }
    end

    context 'when giving a role which is not defined' do
      it { expect{ he.is_temporarily :someone_else }.to raise_error(IAmICan::Error)  }
      it { expect{ he.becomes_a :someone_else }.to raise_error(IAmICan::Error)  }

      context 'when setting use_after_define to false' do
        before { their.ii_config.use_after_define = false }
        it do
          expect{ he.becomes_a :someone_else }.not_to raise_error
          expect(:someone_else).to be_in(his.stored_role_names)
        end
        after  { their.ii_config.use_after_define = true }
      end
    end

    context 'when giving multi roles' do
      before { he.becomes_a :master, :guest }
      it { expect(his.stored_role_names).to contain(%i[master guest]) }
    end

    context 'when assigning the role which is assigned before' do
      before { he.becomes_a :admin, :admin }
      it { expect(his.stored_role_names).to eq [:admin] }
    end
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
    before { they.has_and_group_roles :vip1, :vip2, :vip3, by_name: :vip }
    before { they.has_and_group_roles :a, :b, :c, by_name: :abc }
    before { he.becomes_a :vip1 }
    it { expect(he.is_in_role_group? :vip).to be_truthy }
    it { expect(he.is_in_role_group? :abc).to be_falsey }
  end
end

RSpec.describe IAmICan::Am do
  let(:people) { User }
  let(:people) { User }
  subject { User.create }
  let(:he) { subject }
  let(:his) { subject }

  before do
    people.have_role :admin, :master, :guest, :dev
  end

  describe '#becomes_a & #temporarily_is' do
    context 'when using #becomes_a (save by default)' do
      before { he.becomes_a :admin }
      it { expect(:admin).to be_in(his.stored_role_names) }
      it { expect(:admin).not_to be_in(his.local_role_names) }

      # TODO: is reasonable?
      context 'and then assign the same role by using #temporarily_is' do
        before { he.temporarily_is :admin }
        it { expect(:admin).to be_in(his.stored_role_names) }
        it { expect(:admin).to be_in(his.local_role_names) }
      end
    end

    context 'when using #temporarily_is (not save)' do
      before { he.temporarily_is :master }
      it { expect(:master).to be_in(his.local_role_names) }
      it { expect(:master).not_to be_in(his.stored_role_names) }
    end

    context 'when giving a role which is not defined' do
      it { expect{ he.temporarily_is :someone_else }
               .to raise_error(IAmICan::Error).with_message(/have not been defined/)  }
      it { expect{ he.becomes_a :someone_else }
               .to raise_error(IAmICan::Error).with_message(/have not been defined/)  }

      context 'when setting use_after_define to false' do
        before { people.ii_config.use_after_define = false }
        it do
          expect{ he.becomes_a :someone_else }.not_to raise_error
          expect(:someone_else).to be_in(his.stored_role_names)
        end
        after  { people.ii_config.use_after_define = true }
      end
    end

    context 'when giving multi roles' do
      before { he.becomes_a :dev, :guest }
      it { expect(his.stored_role_names).to contain(%i[dev guest]) }
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
    before { people.have_and_group_roles :vip1, :vip2, :vip3, by_name: :vip }
    before { people.have_and_group_roles :a, :b, :c, by_name: :abc }
    before { he.becomes_a :vip1 }
    it { expect(he.is_in_role_group? :vip).to be_truthy }
    it { expect(he.is_in_role_group? :abc).to be_falsey }
  end
end

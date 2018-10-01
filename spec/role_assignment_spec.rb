RSpec.describe IAmICan::Role::Assignment do
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

      context 'when setting auto_define_before to true' do
        it do
          expect{ he.becomes_a :someone_else, auto_define_before: true }.not_to raise_error
          expect(:someone_else).to be_in(his.stored_role_names)
        end
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

    describe 'which_can' do
      before { he.becomes_a :coder, which_can: %i[read write], obj: :code }
      it do
        expect(:coder).to be_in(people.defined_stored_role_names)
        expect(UserRole.defined_stored_pms_names).to contain(%i[read_code write_code])
        expect(UserRole.which(name: :coder).can? :read, obj: :code).to be_truthy
        expect(he.is? :coder).to be_truthy
        expect(he.can? :read, obj: :code).to be_truthy
      end
    end
  end

  describe '#falls_from' do
    context 'when saving' do
      before { he.becomes_a :admin }
      it do
        expect(he.is? :admin).to be_truthy
        expect{ he.falls_from :admin }.not_to raise_error
        expect(he.is? :admin).to be_falsey
      end

      it { expect{ he.falls_from :someone_else }
               .to raise_error(IAmICan::Error).with_message(/have not been defined/)  }
    end

    context 'when local' do
      before { he.temporarily_is :admin }
      it do
        expect(he.is? :admin).to be_truthy
        expect{ he.falls_from :admin, saved: false }.not_to raise_error
        expect(he.is? :admin).to be_falsey
      end

      it { expect{ he.falls_from :someone_else, saved: false }
               .to raise_error(IAmICan::Error).with_message(/have not been defined/)  }
    end
  end
end

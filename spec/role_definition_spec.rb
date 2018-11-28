RSpec.describe IAmICan::Role::Definition do
  subject { User }
  let(:people) { subject }
  let(:role_group_records) { UserRoleGroup }

  cls_cleaning

  describe '.have_role' do
    context 'normally' do
      before { people.have_role :admin }
      it { expect(:admin).to be_in(UserRole.all.names) }
    end

    context 'when giving multi roles' do
      before { people.have_roles :master, :guest }
      it { expect(UserRole.all.names).to contain(%i[master guest]) }
    end

    context 'when defining the role which is defined before' do
      before { people.have_roles :admin }

      it 'saves the first one, and raise error in saving the last one' do
        expect{ people.have_roles :admin }
            .to raise_error(IAmICan::Error).with_message(/\[:admin\] have been used by other roles/)
        expect(UserRole.all.names.size).to eq 1
      end
    end
  end

  describe '.group_roles' do
    before { people.have_and_group_roles :vip1, :vip2, :vip3, by_name: :vip }
    it { expect(people.defined_role_groups).to include(vip: %i[vip1 vip2 vip3]) }
    it { expect(role_group_records.last.name).to eq 'vip' }
    it { expect(role_group_records.last.member_ids).to have_size 3 }

    context 'when multi-calling by the same group name' do
      before { people.have_and_group_roles :vip4, by_name: :vip }
      it { expect(people.defined_role_groups).to include(vip: %i[vip1 vip2 vip3 vip4]) }
      it 'pushes the NEW members into the list' do
        expect(role_group_records.last.member_ids).to have_size(4)
      end
    end

    context 'nested group' do
      # TODO
    end

    context 'when giving some roles which have not been stored' do
      #
    end

    context 'which_can' do
      #
    end

    describe '.members_of_role_group' do
      it { expect(people.members_of_role_group :vip).to eq(%i[vip1 vip2 vip3]) }
    end
  end
end

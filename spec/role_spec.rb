RSpec.describe IAmICan::Role do
  subject { User }
  let(:their_role_records) { UserRole }
  let(:their_role_group_records) { UserRoleGroup }
  let(:they) { subject }
  let(:their) { subject }

  describe '#has_role & #declare_role' do
    context 'when using #has_role' do
      before { they.has_role :admin }
      it do
        expect(:admin).to be_in(their.stored_role_names)
        expect(:admin).not_to be_in(their.local_roles.names)
      end
    end

    context 'when using #declare_role' do
      before { they.declare_role :admin }
      it do
        expect(:admin).to be_in(their.local_roles.names)
        expect(:admin).not_to be_in(their.stored_role_names)
      end
    end

    context 'when giving multi roles' do
      before { they.has_roles :master, :guest }
      it { expect(their.stored_role_names).to contain(%i[master guest]) }
    end

    context 'when defining the role which is defined before' do
      it 'saves the first one, and raise error in saving the last one' do
        expect{ they.has_roles :admin, :admin }.to raise_error(IAmICan::Error)
        expect(their.stored_role_names.size).to eq 1
      end
    end
  end

  describe '#group_roles' do
    before { they.has_and_group_roles :vip1, :vip2, :vip3, by_name: :vip }
    it { expect(their.role_groups).to include(vip: %i[vip1 vip2 vip3]) }
    it { expect(their_role_group_records.last.name).to eq 'vip' }
    it { expect(their_role_group_records.last.member_ids).to have_size 3 }

    context 'when multi-calling by the same group name' do
      before { they.has_and_group_roles :vip4, by_name: :vip }
      it { expect(their.role_groups).to include(vip: %i[vip1 vip2 vip3 vip4]) }
      it 'pushes the NEW members into the list' do
        expect(their_role_group_records.last.member_ids).to have_size(4)
      end
    end

    context 'when giving role name which is used by defining a group' do
      it { expect{ they.has_role :vip }.to raise_error(IAmICan::Error) }
    end

    context 'nested group' do
      # TODO
    end

    context 'when giving some roles which have not been stored' do
      #
    end

    describe '#members_of_role_group' do
      it { expect(their.members_of_role_group :vip).to eq(%i[vip1 vip2 vip3]) }
    end
  end
end

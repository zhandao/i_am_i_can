RSpec.describe IAmICan::Am do
  subject { User }
  let(:their_role_records) { UserRole }
  let(:their_role_group_records) { UserRoleGroup }
  let(:they) { subject }
  let(:their) { subject }

  describe '#has_role(s)' do
    before { they.has_role :admin }
    it { expect(:admin).to be_in(their.roles.names) }

    context 'when giving multi roles' do
      before { they.has_roles :master, :guest }
      it { expect(their.roles.keys).to contain(%i[admin guest]) }
    end

    context 'save' do
      before { they.store_role :dev }
      it { expect(their_role_records.last).to have_attributes(name: 'dev', desc: 'Dev') }
    end
  end

  describe '#group_roles' do
    before { they.has_and_group_roles :vip1, :vip2, :vip3, by_name: :vip }
    it { expect(their.role_groups).to include(vip: %i[vip1 vip2 vip3]) }
    # it { expect(their.roles[:vip1]).to include(group: [:vip]) }

    context 'nested group' do
      # TODO
    end

    context 'save' do
      before { they.store_group_roles :a, :b, :c, by_name: :az }
      it { expect(their_role_group_records.last).to have_attributes(name: 'az', member_ids: [2, 3, 4]) }

      context 'when multi-calling by the same group name' do
        before { they.store_group_roles :c, :d, by_name: :az }
        it { expect(their.role_groups).to include(az: %i[a b c d]) }
        it { expect(their_role_group_records.last.member_ids).to have_size(%i[a b c d].size) }
      end
    end

    describe '#members_of_role_group' do
      it { expect(their.members_of_role_group :vip).to eq(%i[vip1 vip2 vip3]) }
    end
  end
end

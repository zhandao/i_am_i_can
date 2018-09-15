RSpec.describe IAmICan::Am do
  subject { User }
  let(:they) { subject }
  let(:their) { subject }

  describe '#has_role(s)' do
    before { they.has_role :admin }
    it { expect(:admin).to be_in(their.roles.names) }

    context 'when giving multi roles' do
      before { they.has_roles :master, :guest }
      it { expect(their.roles.keys).to contain(%i[admin guest]) }
    end

    context 'when defining the role which is defined before' do
      before { they.has_roles :admin }
      it { expect(:admin).to be_in(their.roles.names) }
    end

      describe '#store_role' do
        # TODO
    end
  end

  describe '#group_roles' do
    before { they.has_and_group_roles :vip1, :vip2, :vip3, by_name: :vip }
    it { expect(their.role_groups).to include(vip: %i[vip1 vip2 vip3]) }
    it { expect(their.roles[:vip1]).to include(group: [:vip]) }

    context 'nested group' do
      # TODO
    end
  end
end

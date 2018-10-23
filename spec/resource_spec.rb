RSpec.describe IAmICan::Resource do
  let(:user) { User.create }
  let(:resource) { Resource.create(id: 1) }

  before do
    User.have_role :admin
    UserRole.have_permission :manage, obj: resource
    UserRole.which(name: :admin).can :manage, obj: resource
    user.becomes_a :admin
  end

  describe '.that_allow.to' do
    it('works with single subject') { expect(Resource.that_allow(user).to(:manage)).to eq([ resource ]) }

    before { User.create }
    it('works with subjects') { expect(Resource.that_allow(User.all).to(:manage)).to eq([ resource ]) }
  end
end

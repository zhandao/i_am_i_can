RSpec.describe IAmICan::Permission::Definition do
  subject { UserRole }
  let(:roles) { subject }
  let(:role) { roles.create(name: :admin) }
  let(:permission_records) { UserPermission }
  let(:user) { User.create(id: 1) }

  cls_cleaning

  context '.has_permission' do
    before { roles.has_permission :manage, obj: User }
    it { expect(:manage_User).to be_in roles.defined_stored_pms_names }
    it { expect(permission_records.last).to have_attributes(pred: 'manage', obj_type: 'User', obj_id: nil) }

    context 'when giving multi preds' do
      context 'without obj' do
        before { roles.has_permissions :fly, :run, :jump }
        it { expect(roles.defined_stored_pms_names).to contain(%i[fly run jump])}
        it { expect(permission_records.count).to eq(1+3) }
      end

      context 'with obj' do
        before { roles.has_permissions *%i[read write copy remove], obj: File }
        it { expect(roles.defined_stored_pms_names).to contain(%i[read_File write_File copy_File remove_File])}
        it { expect(permission_records.count).to eq(1+4) }
      end
    end
  end
end

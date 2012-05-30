require 'puppet/modules/vcenter/type_base'

Puppet::Type.newtype(:vc_vm) do
  @doc = "Manage vCenter virtual machines."

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto(:present)
  end

  newparam(:path) do
    desc "The path to the VM, including VM name.  The immediate parent must be a Datacenter."
    isnamevar
  end

  newparam(:connection) do
    desc "The connectivity to vCenter."
    # username:password@vcenter_host
  end

  newparam(:compute_resource) do
    desc "The path to Compute Resource which provides the resource pool and datastore for the VM."
  end

  newparam(:datastore) do
    desc "Name of the datastore"
  end

  autorequire(:vc_datacenter) do
    # autorequire immediate parent Datacenter
    Puppet::Modules::VCenter::TypeBase.get_immediate_parent(self[:path])
  end

end


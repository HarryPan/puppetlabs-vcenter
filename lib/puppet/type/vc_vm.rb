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

  newparam(:dcpath) do
    desc "The path to the parent Datacenter where the VM is hosted."
    isnamevar
  end

  newparam(:name) do
    desc "Name of the VM."
    isnamevar
  end

  # parse_title() in Puppet source lib/puppet/resource.rb explains
  # how this is used:
  # for each [regexp, symbols_and_lambdas] pair
  #   regexp is matched against title
  #   each matched group is then processed with the corresponding lambda
  #   the result is assigned to the param with the corresponding symbol
  def self.title_patterns
    identity = lambda{|x| x}
    [
      # regexp,             symbols_and_lambdas
      [ /^(.+\/)([^\/]+)$/, [
                              [ :dcpath, identity ],
                              [ :name,   identity ],
                            ]
      ]
    ]
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
    Puppet::Modules::VCenter::TypeBase.get_immediate_parent(self[:dcpath])
  end

end


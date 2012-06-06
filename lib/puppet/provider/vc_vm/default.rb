Puppet::Type.type(:vc_vm).provide(:vc_vm) do
  require 'puppet/modules/vcenter/provider_base'
  include Puppet::Modules::VCenter::ProviderBase

  # TODO think about how to move a VM

  @doc = "Manages vCenter VMs."

  def self.instances
    # list all instances of VMs in vCenter.
  end

  def create
    # TODO other VM specs
    if @immediate_parent
      vm_spec = { :name => @vmname,
                  :files => { :vmPathName => @resource[:datastore] },
      }
      parent_path, slash, cr_name = @resource[:compute_resource].rpartition('/')
      compute_resource = find_immediate_parent(
        @root_folder,
        parse_path(parent_path + slash),
        "Invalid path for ComputeResource #{@resource[:compute_resource]}").find_child_by_name(cr_name)

      if (not @immediate_parent.is_datacenter?) or compute_resource == nil:
        raise Puppet::Modules::VCenter::ProviderBase::PathNotFoundError.new(
          "Invalid path for VM #{@dcpath + @vmname}", __LINE__, __FILE__)
      end

      @immediate_parent.real_container.vmFolder.CreateVM_Task(
                :config => vm_spec,
                :pool => compute_resource.resourcePool).wait_for_completion
    else
      raise Puppet::Modules::VCenter::ProviderBase::PathNotFoundError.new(
        "Invalid path for VM #{@dcpath + @vmname}", __LINE__, __FILE__)
    end
  end

  def destroy
    @vm.Destroy_Task.wait_for_completion
  end

  def exists?
    @dcpath ||= @resource[:dcpath]
    @vmname ||= @resource[:name]
    @root_folder ||= get_root_folder(@resource[:connection])
    begin
      @immediate_parent ||= find_immediate_parent(
                    @root_folder,
                    parse_path(@dcpath),
                    "Invalid path for VM #{@dcpath + @vmname}")
      # the immediate parent of a VM must be a Datacenter
      if not @immediate_parent.is_datacenter?
        @immediate_parent = nil
        return false
      end
    rescue Puppet::Modules::VCenter::ProviderBase::PathNotFoundError
      return false
    end
    @vm ||= @immediate_parent.real_container.vmFolder.find(@vmname)
    !!@vm
  end
end


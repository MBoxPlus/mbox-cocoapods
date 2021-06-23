module Pod
  class Podfile

    # 暴露私有函数
    def mbox_install_options(installation_method)
      get_hash_value('installation_method', 'name' => installation_method, 'options' => {})
    end

    alias_method :mbox_pod_install_0314!, :install!
    def install!(installation_method, options = {})
      store_options = mbox_install_options(installation_method)['options'] || {}
      store_options = store_options.merge(options) if options
      mbox_pod_install_0314!(installation_method, store_options)
    end
  end
end

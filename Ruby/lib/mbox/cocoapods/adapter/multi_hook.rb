
module Pod
  class Podfile

    alias_method :mbox_pod_pre_install_0220, :pre_install
    def pre_install(&block)
      @pre_install_callback = nil
      mbox_pod_pre_install_0220(&block)
      @pre_install_callbacks ||= []
      @pre_install_callbacks << [Dir.pwd, @pre_install_callback]
    end

    alias_method :mbox_pod_post_install_0220, :post_install
    def post_install(&block)
      @post_install_callback = nil
      mbox_pod_post_install_0220(&block)
      @post_install_callbacks ||= []
      @post_install_callbacks << [Dir.pwd, @post_install_callback]
    end

    alias_method :mbox_pod_pre_install_0220!, :pre_install!
    def pre_install!(installer)
      if @pre_install_callbacks.blank?
        false
      else
        @pre_install_callbacks.each do |path, block|
          Dir.chdir(path) do
            @pre_install_callback = block
            mbox_pod_pre_install_0220!(installer)
          end
        end
        true
      end
    end

    alias_method :mbox_pod_post_install_0220!, :post_install!
    def post_install!(installer)
      if @post_install_callback.blank?
        false
      else
        @post_install_callbacks.each do |path, block|
          Dir.chdir(path) do
            @post_install_callback = block
            mbox_pod_post_install_0220!(installer)
          end
        end
      end
    end
  end
end


module Pod
  module Downloader
    class Base
      class << self

        def parse_git_url(url)
          if url =~ /git@(.+):(.+?)\/(.+?)(\.git|$)/ || 
            url =~ /https?:\/\/(.+?)\/(.+?)\/(.+?)(\.git|$)/
            # match `git@github.com:AppScaffold/ASCocoaCategory.git`
            # match `https://github.com/AppScaffold/ASCocoaCategory.git`
            #
            # match `https://chromium.googlesource.com/webm/libwebp`
            host = $1
            group = $2
            name = $3
            return host, group, name
          end
          return nil
        end

        def download_options(origin_options)
          nil
        end

        def check_status(target, param)
          # Do nothing if success
        end
      end
    end

    class << self
      alias_method :mbox_download_source, :download_source
      def download_source(target, params)
        mparams = downloader_class_by_key.values.map { |klass|
          options = params.dup
          if klass.options.include?(:origin_source) && options[:origin_source].nil?
            options[:origin_source] = params.dup
          end
          options = klass.download_options(options)
          [klass, options] if options
        }.compact

        _, origin_klass = self.class_for_options(params)
        mparams << [origin_klass, params.dup] if origin_klass

        mparams.uniq! { |k, v| k }
        mparams = mparams.partition { |k, v| k != origin_klass }.flatten(1)

        error = nil
        mparams.each do |klass, param|
          begin
            v = mbox_download_source(target, param)
            klass.check_status(target, param)
            if param == params
              return v
            else
              return params
            end
          rescue => e
            error = e
          end
        end
        raise error

      end
    end
  end
end

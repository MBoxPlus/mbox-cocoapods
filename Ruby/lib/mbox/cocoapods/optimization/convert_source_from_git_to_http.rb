require 'cocoapods-downloader/http'

# 替换 Git 地址为 HTTPS 地址

module Pod
  module Downloader
    class << self
      alias_method :mbox_gitlab_token_downloader_class_by_key, :downloader_class_by_key
      def downloader_class_by_key
        v = mbox_gitlab_token_downloader_class_by_key
        v[:gitlab_token] = GitLabToken
        v
      end
    end

    class GitLabToken < Http
      class << self
        def download_options(origin_options)
          convert_git_to_http(origin_options)
        end

        def check_status(target, param)
          gitattr_file = File.join target, '.gitattributes'
          if File.exist?(gitattr_file)
            # 包含 lfs 文件
            if File.read(gitattr_file).include?('lfs')
              UI.puts "GitLabToken Downloader do not support `git-lfs`, fallback!"
              raise DownloaderError, "GitLabToken Downloader do not support `git-lfs`, download failed!"
            end
          end
        end

        HOST_TOKEN = {}
        LOCAL_IPS = []

        # 检测域名是否是本地网络
        def check_host_is_localnet(host)
          info = `ping -c 1 -t 1 "#{host}" | head -1`
          if info =~ /.+\(([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\).+/
            ip_address = $1
            require 'ipaddr'
            ip = IPAddr.new(ip_address).to_i

            if LOCAL_IPS.empty?
              # > 10.0.0.0- 10.255.255.255:(class A)
              # > 172.16.0.0-172.31.255.255:(class B)
              # > 192.168.0.0-192.168.255.255:(class C)
              [['10.0.0.0', '10.255.255.255'],
              ['172.16.0.0', '172.31.255.255'],
              ['192.168.0.0', '192.255.255.255']].map do |startIP, endIP|
                LOCAL_IPS << [IPAddr.new(startIP).to_i, IPAddr.new(endIP).to_i]
              end
            end
            LOCAL_IPS.each do |startIP, endIP|
              return true if ip > startIP && ip < endIP
            end
          end
          false
        end

        def env(key)
          v = ENV[key]
          return nil if v.nil? || v.length == 0
          return v
        end

        # 注入 Gitlab 身份认证 token
        def inject_token(host, url)
          key = host.gsub(".", "_").upcase
          token_type = nil
          unless HOST_TOKEN.has_key?(key)
            if check_host_is_localnet(host)
              # 本地网络服务器必须使用 token 验证
              token_type = "PRIVATE_TOKEN" if env("#{key}_PRIVATE_TOKEN")
              token_type = "ACCESS_TOKEN" if env("#{key}_ACCESS_TOKEN")
            else
              # 外部服务器根据 ENV 判断是否需要验证
              token_type = "PRIVATE_TOKEN" if env("#{key}_PRIVATE_TOKEN")
              token_type = "ACCESS_TOKEN" if env("#{key}_ACCESS_TOKEN")
            end
            HOST_TOKEN[key] = token_type
          else
            token_type = HOST_TOKEN[key]
          end
          if token_type
            token_key = "#{key}_#{token_type}"
            if env(token_key)
              url << "?" if url.index("?").nil?
              url << "&#{token_type.downcase}=#{ENV[token_key]}"
              # 需要注入 token 且注入成功
              return true
            else
              # 需要注入 token 但是注入失败
              return false
            end
          end
          # 不需要注入 Token，可以直接转 http
          false
        end

        def convert_git_to_http(origin_hash)
          hash = origin_hash.dup
          git = hash[:git]
          ref = hash[:commit] ? hash[:commit][0..9] : hash[:tag]
          return if git.nil? || ref && hash[:submodules]
          git.strip!
          host, group, name = parse_git_url(git)
          if host && group && name
            white_list = ENV['MBOX_GIT_TO_HTTPS_WHITE_LIST']
            unless white_list.nil?
              white_list = white_list.split(',').map(&:downcase)
              if white_list.include?("#{group}/#{name}".downcase)
                UI.message "Git2Http skip download `#{group}/#{name}` due to the `MBOX_GIT_TO_HTTPS_WHITE_LIST` (#{ENV['MBOX_GIT_TO_HTTPS_WHITE_LIST']})."
                return nil
              end
            end
            http = ""
            if host == "github.com"
              # Github 路径
              http = "https://codeload.github.com/#{group}/#{name}/zip/#{ref}"
              hash[:type] = "zip"
              hash[:flatten] = true
            elsif host =~ /.*\.googlesource\.com/
              # Google Source 路径
              http = "#{git}/+archive/#{ref}.tar.gz"
            else
              # gitlab 模式路径
              url = "https://#{host}/#{group}/#{name}/repository/archive.zip?ref=#{ref}"
              return unless inject_token(host, url)
              http = url
              hash[:flatten] = true
            end
            sha = hash[:sha1] || hash[:sha256]
            if sha
              http += "?" if http.index("?").nil?
              http += "&X-sha=#{sha}"
            end
            hash[:gitlab_token] = http
            hash.delete(:git)
            hash.delete(:tag)
            hash.delete(:commit)
            hash.delete(:branch)
            return hash
          end
        end

      end
    end
  end
end

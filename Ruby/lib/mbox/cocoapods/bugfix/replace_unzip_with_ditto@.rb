require 'cocoapods-downloader/http'

module Pod
    module Downloader

        # macos 10.13.4 use APFS, it's unzip have a encoding bug to Chinese Path.
        # We use `ditto` instead of `unzip`
        # see https://github.com/CocoaPods/CocoaPods/issues/7711
        class RemoteFile < Base
            executable :ditto
            def unzip!(*args)
                flag = args.index("-d")
                unpack_from = args[flag - 1]
                unpack_to = args[flag + 1]
                ditto! '-x', '-k', '--sequesterRsrc', '-rsrc', unpack_from, unpack_to
            end
        end
    end
end

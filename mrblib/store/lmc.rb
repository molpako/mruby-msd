module Msd::Store::Prefixer; end
module Msd
  class Store
    class Lmc
      include HashKeys
      include Prefixer
      def initialize(namespace)
        @namespace = namespace
      end

      def connect
        @_c ||= ::Cache.new :namespace => @namespace
      end

      def connect?
        @_c
      end

      def drop
        @_c = nil
        ::Cache.drop :namespace => @namespace, :force => true
      end

      def fetch(key)
        key = set_prefix(key)
        connect unless connect?
        if has_keys?
          begin
            JSON.parse(@_c[key])
          rescue
            @_c[key]
          end
        else
          @_c[key]
        end
      end

      def cache(key, val)
        key = set_prefix(key)
        connect unless connect?
        if has_keys?
          @_c[key] = val.to_json
        else
          @_c[key] = val
        end
      end

      def purge(key)
        key = set_prefix(key)
        connect unless connect?
        @_c.delete(key)
      end

      alias_method :before_connect_retry, :drop
      alias_method :before_cache_retry, :drop
      alias_method :before_fetch_retry, :drop
      alias_method :before_purge_retry, :drop
    end
  end
end

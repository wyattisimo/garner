module Garner
  module Mixins
    module Mongoid
      module Document
        extend ActiveSupport::Concern
        include Garner::Cache::Binding

        included do
          extend Garner::Cache::Binding

          def self.cache_key
            _latest_by_updated_at.try(:cache_key)
          end

          def self.proxy_binding
            _latest_by_updated_at
          end

          def self.identify(id)
            Garner::Mixins::Mongoid::Identity.from_class_and_id(self, id)
          end

          def self.garnered_find(id)
            return nil unless (binding = identify(id))
            identity = Garner::Cache::Identity.new
            identity.bind(binding).key({ :source => :garnered_find }) { find(id) }
          end

          after_create    :_garner_after_create
          after_update    :_garner_after_update
          after_destroy   :_garner_after_destroy

          protected
          def self._latest_by_updated_at
            # Only find the latest if we can order by :updated_at
            return nil unless fields["updated_at"]
            only(:_id, :_type, :updated_at).order_by({
              :updated_at => :desc
            }).first
          end
        end

      end
    end
  end
end

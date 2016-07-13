# You should replace InMemorySessionStore with what you will be using
# in Production. For example a model called "Shop":
#
# SpiffyStoresSessionRepository.storage = 'Shop'
#
# Interface to implement are self.retrieve(id) and self.store(SpiffyStoresAPI::Session)
# Here is how you would add these functions to an ActiveRecord:
#
# class Shop < ActiveRecord::Base
#   def self.store(session)
#     shop = self.new(domain: session.url, token: session.token)
#     shop.save!
#     shop.id
#   end
#
#   def self.retrieve(id)
#     if shop = self.where(id: id).first
#       SpiffyStoresAPI::Session.new(shop.domain, shop.token)
#     end
#   end
# end

SpiffyStoresApp::SessionRepository.storage = InMemorySessionStore

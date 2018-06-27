require 'test_helper'

class TestSessionStore
  attr_reader :storage

  def initialize
    @storage = []
  end

  def retrieve(id)
    storage[id]
  end

  def store(session)
    id = storage.length
    storage[id] = session
    id
  end
end

class TestSessionStoreClass
  def self.store(session)
  end

  def self.retrieve(id)
  end
end

class SpiffyStoresSessionRepositoryTest < ActiveSupport::TestCase
  attr_reader :session_store, :session

  setup do
    @session_store = TestSessionStore.new
    @session = SpiffyStoresAPI::Session.new('shop.spiffystores.com', 'abracadabra')
    SpiffyStoresApp::SessionRepository.storage = session_store
  end

  teardown do
    SpiffyStoresApp::SessionRepository.storage = nil
  end

  test "adding a session to the repository" do
    assert_equal 0, SpiffyStoresApp::SessionRepository.store(session)
    assert_equal session, session_store.retrieve(0)
  end

  test "retrieving a session from the repository" do
    session_store.storage[9] = session
    assert_equal session, SpiffyStoresApp::SessionRepository.retrieve(9)
  end

  test "retrieving a session for an id that does not exist" do
    SpiffyStoresApp::SessionRepository.store(session)
    assert !SpiffyStoresApp::SessionRepository.retrieve(100), "The session with id 100 should not exist in the Repository"
  end

  test "retrieving a session for a misconfigured shops repository" do
    SpiffyStoresApp::SessionRepository.storage = nil
    assert_raises SpiffyStoresApp::SessionRepository::ConfigurationError do
      SpiffyStoresApp::SessionRepository.retrieve(0)
    end

    assert_raises SpiffyStoresApp::SessionRepository::ConfigurationError do
      SpiffyStoresApp::SessionRepository.store(session)
    end
  end

  test "accepts a string and constantizes it" do
    SpiffyStoresApp::SessionRepository.storage = 'TestSessionStoreClass'
    assert_equal TestSessionStoreClass, SpiffyStoresApp::SessionRepository.storage
  end

end

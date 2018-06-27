require 'test_helper'

class OrderUpdateJob < ActiveJob::Base
  def perform; end
end

module SpiffyStoresApp
  class WebhooksControllerTest < ActionDispatch::IntegrationTest
    include ActiveJob::TestHelper

    setup do
      WebhooksController.any_instance.stubs(:verify_request).returns(true)
    end

    test "receives webhook and performs job" do
      send_webhook 'order_update', {foo: :bar}
      assert_response :no_content
      assert_enqueued_jobs 1
    end

    test "passes webhook to the job" do
      webhook = {'foo' => 'bar'}
      job_args = {shop_domain: "test.spiffystores.com", webhook: webhook}

      OrderUpdateJob.expects(:perform_later).with(job_args)

      send_webhook 'order_update', webhook
      assert_response :no_content
    end

    test "returns error for webhook with no job class" do
      assert_raises SpiffyStoresApp::MissingWebhookJobError do
        send_webhook 'test', {foo: :bar}
      end
    end

    private

    def send_webhook(name, data)
      post spiffy_stores_app.webhooks_path(name), params: data, headers: {'HTTP_X_SPIFFY_STORES_SHOP_DOMAIN' => 'test.spiffystores.com'}
    end
  end
end

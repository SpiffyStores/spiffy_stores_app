# frozen_string_literal: true
class AppProxyController < ApplicationController
   include SpiffyStoresApp::AppProxyVerification

  def index
    render layout: false, content_type: 'application/liquid'
  end

end

# frozen_string_literal: true

module Wechat
  class Railtie < ::Rails::Railtie
    config.after_initialize do
      require 'action_controller/wechat_responder'
    end
  end
end

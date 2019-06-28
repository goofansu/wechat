module Wechat
  class ApiBase
    attr_reader :access_token, :client, :jsapi_ticket

    API_BASE    = 'https://api.weixin.qq.com/cgi-bin/'.freeze
    MP_BASE = 'https://mp.weixin.qq.com/cgi-bin/'.freeze
    WXA_BASE    = 'https://api.weixin.qq.com/wxa/'.freeze
    OAUTH2_BASE = 'https://api.weixin.qq.com/sns/'.freeze
    DATACUBE_BASE = 'https://api.weixin.qq.com/datacube/'.freeze
    QYAPI_BASE = 'https://qyapi.weixin.qq.com/cgi-bin/'.freeze

    def callbackip
      get 'getcallbackip'
    end

    def qrcode(ticket)
      client.get 'showqrcode', params: { ticket: ticket }, base: MP_BASE, as: :file
    end

    def media(media_id)
      get 'media/get', params: { media_id: media_id }, as: :file
    end

    def media_hq(media_id)
      get 'media/get/jssdk', params: { media_id: media_id }, as: :file
    end

    def media_create(type, file)
      post_file 'media/upload', file, params: { type: type }
    end

    def media_uploadimg(file)
      post_file 'media/uploadimg', file
    end

    def media_uploadnews(mpnews_message)
      post 'media/uploadnews', mpnews_message.to_json
    end

    def clear_quota
      post 'clear_quota', JSON.generate(appid: Wechat.config[:appid])
    end

    def addvoicetorecofortext(voice_id, file_format = '', lang = 'zh_CN')
      post 'media/voice/addvoicetorecofortext', nil, params: { format: file_format, voice_id: voice_id, lang: lang }, base: API_BASE
    end

    def queryrecoresultfortext(voice_id, lang = 'zh_CN')
      post 'media/voice/queryrecoresultfortext', nil, params: { voice_id: voice_id, lang: lang }, base: API_BASE
    end

    protected

    def get(path, headers = {})
      with_access_token(headers[:params]) do |params|
        client.get path, headers.merge(params: params)
      end
    end

    def post(path, payload, headers = {})
      with_access_token(headers[:params]) do |params|
        client.post path, payload, headers.merge(params: params)
      end
    end

    def post_file(path, file, headers = {})
      with_access_token(headers[:params]) do |params|
        client.post_file path, file, headers.merge(params: params)
      end
    end

    def with_access_token(params = {}, tries = 2)
      params ||= {}
      yield(params.merge(access_token: access_token.token))
    rescue AccessTokenExpiredError
      access_token.refresh
      retry unless (tries -= 1).zero?
    end
  end
end

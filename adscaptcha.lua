--[[
  Plugin Name: AdsCaptcha
  Plugin URI: http://github.com/develCuy/adscaptcha
  Description: Why pay for CAPTCHAs when AdsCaptcha can make you money?
               AdsCaptcha provides high-level internet security, and you earn a
               share of every typed ad. Now that’s efficient!
  Version: 0.1
  Author: Fernando Paredes Garcia <fernando@develcuy.com>
  Author URI: http://www.develCuy.com
]]

local m = {
  version = ('AdsCaptcha/0.1 (%s)'):format(_VERSION or 'Lua 5.1'),
  base_uri = 'https://api.minteye.com',
}

local _SERVER = function (var) return os.getenv(var) or '' end
local uuid = require 'uuid'
local json = require 'dkjson'
local http = require 'socket.http'

-- Try to load Seawolf library
do
  local _
  loaded, value = pcall(require, 'seawolf.variable')
  if loaded then
    m.debug = value
  end
end

local tconcat = table.concat

-- Configuration
config = {
  debug = false,
}

-- Functions

local function dolog(msg)
  if config.debug then
    local fh = io.open('/tmp/adscaptcha.log', 'a+')
    return fh:write(("%s: %s\n"):format(os.date('%Y-%m-%d %H:%M:%S', os.time()), debug.print_r(msg, 1)))
  end
end

local function api_call(uri, request_body)
  if request_body == nil then
    request_body = {}
  end

  local response_body = {}
  local request_uri = ''
  local output = {}

  request_uri = m.base_uri .. '/' .. (uri or '')

  local res, code, headers = http.request{
    url = request_uri,
    method = 'POST',
    headers = {
      ['host'] = 'AdsCaptcha',
      ['content-type'] = 'application/x-www-form-urlencoded; charset=utf-8',
      ['content-length'] = request_body:len(),
    },
    source = ltn12.source.string(request_body),
    sink = ltn12.sink.table(response_body),
  }

  if res == 1 then
    output.response = json.decode(tconcat(response_body) or '')
  end

  return output
end

function m.getCaptcha(captchaId, publicKey)
  local dummy, urlGet, urlNoScript, params, result

  dummy = uuid.new()
  urlGet = m.base_uri .. '/Get.aspx'
  urlNoScript = m.base_uri .. '/NoScript.aspx'
  params = '?CaptchaId='  .. captchaId ..
          '&PublicKey=' .. publicKey ..
          '&Dummy=' .. dummy

  result  = ([[<script src="%s" type="text/javascript"></script>
<noscript>
<iframe src="%s" width="300" height="110" frameborder="0" marginheight="0" marginwidth="0" scrolling="no"></iframe>
<table>
<tr><td>Type challenge here:</td><td><input type="text" name="adscaptcha_response_field" value="" /></td></tr>
t<tr><td>Paste code here:</td><td><input type="text" name="adscaptcha_challenge_field" value="" /></td></tr>
</table>
</noscript>]]):format(urlGet .. params, urlNoScript .. params)

  return result 
end

function m.validateCaptcha(captchaId, privateKey, challengeCode, userResponse, remoteAddress)
  local host, path, data

  path = 'Validate.aspx'

  data = (
    'CaptchaId=%s&' ..
    'PrivateKey=%s&' ..
    'ChallengeCode=%s&' ..
    'UserResponse=%s&' ..
    'RemoteAddress=%s'
  ):format(captchaId, privateKey, challengeCode, userResponse, remoteAddress)

  return api_call(path, data)
end

return m
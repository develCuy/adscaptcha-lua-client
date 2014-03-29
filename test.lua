local _SERVER = os.getenv
local AdsCaptcha = require 'adscaptcha'

local captchaId = 0000
local publicKey = 'YOUR public KEY'
local privateKey = 'YOUR private KEY'

print(AdsCaptcha.getCaptcha(captchaId, publicKey))

_POST = {
  adscaptcha_challenge_field = '',
  adscaptcha_response_field = '',
}

local challengeValue = _POST.adscaptcha_challenge_field
local responseValue  = _POST.adscaptcha_response_field
local remoteAddress  = _SERVER 'REMOTE_ADDR'

if 'true' == AdsCaptcha.validateCaptcha(captchaId, privateKey, challengeValue, responseValue, remoteAddress) then
  print 'Correct answer, continue with your submission process'
else
  print 'Wrong answer, you may display a new minteye Captcha and add an error args'
end

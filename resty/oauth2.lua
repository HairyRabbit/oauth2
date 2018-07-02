--[[
OAuth2 toolkit, used for OAuth2 login, includes some providers:

1. Github
2. QQ
3. Wechat
4. Weibo
5. Dingtalk
6. Alipay

Author:

   HairyRabbit (2018)

License:

   MIT
]]

local cjson = require "cjson"

local _M = {}

local oauth2_secret = cjson.decode(os.getenv("OAUTH2_SECRET"))

local function sign(iat, typ)
   local opt = {
      iat = iat,
      typ = typ,
      key = oauth2_secret
   }

   ngx.log(ngx.ALERT, cjson.encode(opt))
   return ngx.md5(ngx.encode_args(opt))
end

local function make_token(typ)
   local now = tostring(ngx.now())
   local opt = {
      iat = now,
      typ = typ,
      sig = sign(now, typ)
   }

   local ret = ngx.encode_base64(ngx.encode_args(opt))

   return ret
end

local function request()
   local args, err = ngx.req.get_uri_args()

   if "truncated" == err then
      return nil, "Too many request arguments"
   end

   local typ = string.sub(args["typ"], 1)
   args["state"] = make_token(typ)
   args["typ"] = nil

   ngx.log(ngx.ALERT, cjson.encode(args))

   local url = string.format("/oauth2/%s/login?%s", typ, ngx.encode_args(args))
   ngx.log(ngx.ALERT, url)
   ngx.redirect(url)
end

local function receive()
   local args, err = ngx.req.get_uri_args()

   if "truncated" == err then
      return nil, "Too many request arguments"
   end

   local code = args["code"]
   local state = args["state"]

   local opt = ngx.decode_args(ngx.decode_base64(state))
   local typ = opt["typ"]
   local ait = opt["ait"]
   local sig = opt["sig"]

   if not sig == sign(ait, typ) then
      return nil, "sign verify invalid"
   end

   local url = string.format("/oauth2/%s", typ)
   local req = {
      args = {
         code = code
      }
   }

   local res = ngx.location.capture(url, req)
   return cjson.encode(res.body), nil
end

_M.request = request
_M.receive = receive

return _M

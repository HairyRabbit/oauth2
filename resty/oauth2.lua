--[[

OAuth2 toolkit, used for OAuth2 login, includes providers

1. Github
2. QQ
3. Wechat
4. Weibo
5. Dingtalk
6. Alipay


Author:

   2018 © HairyRabbit <yfhj1990@hotmail.com>
]]

local cjson = require "cjson"

-- @module oauth2
local _M = {}

local oauth2_secret = cjson.decode(os.getenv("OAUTH2_SECRET"))

--- make sign from secret
-- @param iat timestamp
-- @param typ provider type
-- @return sign or nil
-- @return nil or errors
local function sign(iat, typ)

   -- assert secrect

   if not oauth2_secret then
      return nil, "The environment variable 'OAUTH2_SECRECT' not set"
   end

   -- assert typ

   if not typ then
      return nil, "Argument 'typ' was required"
   end

   local opt = {
      iat = iat,
      typ = typ,
      key = oauth2_secret
   }

   return ngx.md5(ngx.encode_args(opt))
end


--- make token
-- @param typ provider type
-- @return token or nil
-- @return nil or errors
local function token(typ)

   -- assert typ

   if not typ then
      return nil, "Argument 'typ' was required"
   end

   local now = tostring(ngx.now())

   -- make sign

   local sig, err = sign(now, typ)

   if err then
      return nil, err
   end

   -- make token

   local opt = {
      iat = now,
      typ = typ,
      sig = sig
   }

   local ret = ngx.encode_base64(ngx.encode_args(opt))

   return ret
end


--- request code, redirect to provider login page
-- @return ok or nil
-- @return nil or errors
local function request()
   local args, err = ngx.req.get_uri_args()

   if "truncated" == err then
      return nil, "Too many request arguments"
   end

   -- assert request type

   if not args["typ"] then
      return nil, "Argument 'typ' was required"
   end

   -- make token and erasure type

   local typ = string.sub(args["typ"], 1)
   local tok, err = token(typ)

   if err then
      return nil, err
   end

   args["state"] = tok
   args["typ"] = nil

   -- redirect to login page

   local url = string.format("/oauth2/%s/login?%s", typ, ngx.encode_args(args))
   ngx.redirect(url)

   return true
end


--- received from service redirect
-- @return page or n
local function receive()
   local args, err = ngx.req.get_uri_args()

   if "truncated" == err then
      return nil, "Too many request arguments"
   end

   -- assert code and state

   local code = args["code"]
   local stat = args["state"]

   if not code then
      return nil, "Argument 'code' was required"
   end

   if not stat then
      return nil, "Argument 'state' was required"
   end

   -- verify sign

   local opt = ngx.decode_args(ngx.decode_base64(stat))
   local typ = opt["typ"]
   local ait = opt["ait"]
   local sig = opt["sig"]
   local val, err = sign(ait, typ)

   if err then
      return nil, err
   end

   if not sig == val then
      return nil, "sign invalid"
   end

   -- request provider service
   local url = string.format("/oauth2/%s", typ)
   local req = {
      args = {
         code = code
      }
   }

   local res = ngx.location.capture(url, req)
   return cjson.decode(res.body)
end

_M.request = request
_M.receive = receive

return _M

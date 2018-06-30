--[[
   QQ OAuth2.0

Author
]]

local cjson = require "cjson"

local _M = {}

local app_id     = cjson.decode(os.getenv("OAUTH2_APPID_QQ"))
local app_secret = cjson.decode(os.getenv("OAUTH2_APPSECRET_QQ"))
local redirect   = cjson.decode(os.getenv("OAUTH2_REDIRECT"))
local url_token  = "/oauth2/qq/token"
local url_openid = "/oauth2/qq/openid"
local url_user   = "/oauth2/qq/user"

local function get_code()
   local args, err = ngx.req.get_uri_args()

   if "truncated" == err then
      return nil, "Too many request arguments"
   end

   local code = args["code"]

   if not code then
      return nil, "No code found"
   else
      return code, nil
   end
end


local function body_parse(body)
   local re = [[callback\( ([^\)]+) \)]]
   local ma, err = ngx.re.match(body, re, "jo")

   if not ma then
      return nil
   end

   return cjson.decode(ma[1])
end


local function get_token(code)

   -- request service

   local req_opt = {
      args = {
         grant_type    = "authorization_code",
         client_id     = app_id,
         client_secret = app_secret,
         code          = code,
         redirect_uri  = redirect
      }
   }

   local res = ngx.location.capture(url_token, req_opt)


   -- handle errors from qq token service

   local err = body_parse(res.body)
   if err then
      return nil, err["error_description"]
   end

   -- decode content
   ngx.log(ngx.ALERT, cjson.encode(ngx.decode_args(res.body)))
   local token = ngx.decode_args(res.body)["access_token"]
   return token, nil
end


local function get_openid(token)

   -- send request to qq server

   local req_opt = {
      args = {
         access_token = token
      }
   }

   local res = ngx.location.capture(url_openid, req_opt)

   -- parse received

   local ret = body_parse(res.body)
   if not ret then
      return nil, "something wrong when parse body"
   end

   -- handle errors

   local err = ret["error_description"]

   if err then
      return nil, err
   end

   -- get openid

   return ret["openid"], nil
end


local function get_user(token, openid)

   -- send request to qq server

   local req_opt = {
      args = {
         access_token       = token,
         oauth_consumer_key = app_id,
         openid             = openid
      }
   }

   local res = ngx.location.capture(url_user, req_opt)

   -- parse received
   local rec = cjson.decode(res.body)

   -- handle errors

   local msg = rec["msg"]

   if not "" == msg then
      return nil, msg
   end

   -- get user profile

   local ret = {
      name   = rec["nickname"],
      avatar = rec["figureurl_qq_2"] or rec["figureurl_qq_1"]
   }

   return ret, nil
end

-- Main

local code, err = get_code()

if err then
   ngx.log(ngx.ERR, err)
   ngx.status = ngx.HTTP_BAD_REQUEST
   ngx.eof()
end

ngx.log(ngx.ALERT, code)

local token, err = get_token(code)

if err then
   ngx.log(ngx.ERR, err)
   ngx.status = ngx.HTTP_BAD_REQUEST
   ngx.eof()
end

ngx.log(ngx.ALERT, token)

local openid, err = get_openid(token)

if err then
   ngx.log(ngx.ERR, err)
   ngx.status = ngx.HTTP_BAD_REQUEST
   ngx.eof()
end

ngx.log(ngx.ALERT, openid)

local user, err = get_user(token, openid)

if err then
   ngx.log(ngx.ERR, err)
   ngx.status = ngx.HTTP_BAD_REQUEST
   ngx.eof()
end

ngx.log(ngx.ALERT, cjson.encode(user))
ngx.say(cjson.encode(user))

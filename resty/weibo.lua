--[[

OAuth2 provider for weibo.com

]]

local cjson = require "cjson"

local _M = {}

local app_id     = cjson.decode(os.getenv("OAUTH2_APPID_WEIBO"))
local app_secret = cjson.decode(os.getenv("OAUTH2_APPSECRET_WEIBO"))
local redirect   = cjson.decode(os.getenv("OAUTH2_REDIRECT"))
local url_token  = "/oauth2/weibo/token"
local url_user   = "/oauth2/weibo/user"

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

local function get_token(code)

   -- request service

   local req_opt = {
      method = ngx.HTTP_POST,
      args = {
         grant_type    = "authorization_code",
         client_id     = app_id,
         client_secret = app_secret,
         code          = code,
         redirect_uri  = redirect
      }
   }

   local res = ngx.location.capture(url_token, req_opt)

   -- decode content
   ngx.log(ngx.ALERT, res.body)
   local ret = cjson.decode(res.body)
   local token = ret["access_token"]
   local uid = ret["uid"]

   return { token = token, uid = uid }, nil
end

local function get_user(token)

   -- send request to qq server

   local req_opt = {
      args = {
         access_token = token["token"],
         uid          = token["uid"]
      }
   }

   local res = ngx.location.capture(url_user, req_opt)

   -- parse received
   local rec = cjson.decode(res.body)

   -- get user profile

   local ret = {
      typ    = "weibo",
      uid    = rec["idstr"],
      name   = rec["screen_name"],
      avatar = rec["avatar_hd"] or rec["avatar_large"]
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

ngx.log(ngx.ALERT, cjson.encode(token))

local user, err = get_user(token, openid)

if err then
   ngx.log(ngx.ERR, err)
   ngx.status = ngx.HTTP_BAD_REQUEST
   ngx.eof()
end

ngx.log(ngx.ALERT, cjson.encode(user))
ngx.say(cjson.encode(user))

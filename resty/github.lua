--[[

OAuth2 provider for github

Author:

   2018 © HairyRabbit <yfhj1990@hotmail.com>
]]

local cjson = require "cjson"

local _M = {}

local app_id     = cjson.decode(os.getenv("OAUTH2_APPID_GITHUB"))
local app_secret = cjson.decode(os.getenv("OAUTH2_APPSECRET_GITHUB"))
local redirect   = cjson.decode(os.getenv("OAUTH2_REDIRECT"))
local url_token  = "/oauth2/github/token"
local url_user   = "/oauth2/github/user"

local function get_code()
   local args, err = ngx.req.get_uri_args()

   if "truncated" == err then
      return nil, "Too many request arguments"
   end

   local code = args["code"]

   if not code then
      return nil, "No code found"
   end

   return code
end

local function get_token(code)

   -- request service

   local req_opt = {
      method = ngx.HTTP_POST,
      args = {
         client_id     = app_id,
         client_secret = app_secret,
         code          = code,
         redirect_uri  = redirect
      }
   }

   local res = ngx.location.capture(url_token, req_opt)

   -- decode content
   ngx.log(ngx.ALERT, res.body)
   local ret, err = ngx.decode_args(res.body)

   if "truncated" == err then
      return nil, "Too many request arguments"
   end


   local tok = ret["access_token"]

   return tok
end

local function get_user(token)

   -- send request to qq server

   local req_opt = {
      args = {
         access_token = token,
      }
   }

   -- ngx.req.set_header("Content-Type", "application/json;charset=utf8");
   -- ngx.req.set_header("Accept", "application/json");
   -- ngx.req.clear_header("Accept-Encoding");
   local res = ngx.location.capture(url_user, req_opt)

   -- parse received
   local rec = cjson.decode(res.body)

   -- get user profile

   local ret = {
      typ    = "github",
      uid    = rec["id"],
      name   = rec["login"],
      avatar = rec["avatar_url"]
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

local user, err = get_user(token)

if err then
   ngx.log(ngx.ERR, err)
   ngx.status = ngx.HTTP_BAD_REQUEST
   ngx.eof()
end

ngx.log(ngx.ALERT, cjson.encode(user))
ngx.say(cjson.encode(user))

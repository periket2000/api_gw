local auth_header = ngx.req.get_headers()["x-auth-token"]
local gserver = "https://app2.mesos.local/authenticate"
local gserver_auth = "https://app2.mesos.local/login"

if auth_header == nil then
    ngx.say("No x-auth-token header included \n-> Access Denied \n-> login at ", gserver_auth)
    return
end

-- authenticate
local http = require "resty.http"
local httpc = http.new()
local res, err = httpc:request_uri(gserver, {
   method = "POST",
   body = "",
   ssl_verify = false,
   headers = {
      ["x-auth-token"] = auth_header,
      ["Content-Type"] = "application/json",
   }
})

if not res then
    ngx.say("failed to request: ", err)
    return
end

if res.status == ngx.HTTP_OK then
    return
end

if res.status == 401 then
    ngx.exit(401)
end

if res.status == ngx.HTTP_FORBIDDEN then
    ngx.exit(res.status)
end

ngx.exit(ngx.HTTP_FORBIDDEN)

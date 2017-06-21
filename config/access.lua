local cjson = require "cjson"
local json = cjson.new()

-- request vars
local method = ngx.var.request_method
local auth_header = ngx.req.get_headers()["x-auth-token"]
local gserver = "https://app2.mesos.local/apps/api_gw/roles"
local gserver_auth = "https://app2.mesos.local/login"

if auth_header == nil then
    ngx.say("No x-auth-token header included \n-> Access Denied \n-> login at ", gserver_auth)
    return
end

-- authenticate
local http = require "resty.http"
local httpc = http.new()
local res, err = httpc:request_uri(gserver, {
   method = "GET",
   body = "",
   ssl_verify = false,
   headers = {
      ["x-auth-token"] = auth_header,
      ["Content-Type"] = "application/json",
   }
})


if res.status == ngx.HTTP_OK then
    -- set up json response in a table
    local data = json.decode(res.body)
    if data.roles ~= nil then
        --file = io.open("/etc/nginx/test.txt", "a")
        for k,v in pairs(data.roles[1]) do
            if k == "nombre_rol" and v == "api_gw_writer" then
                -- file:write(k, " -> ", v, " : ", method, "\n")
                return
            end
            if k == "nombre_rol" and v == "api_gw_reader" and method == "GET" then
                -- file:write(k, " -> ", v, " : ", method, "\n")
                return
            end
        end
    end
end

if res.status == 401 then
    ngx.exit(401)
end

ngx.exit(ngx.HTTP_FORBIDDEN)

require("io")
local json = require("cjson")

-- Based on https://gist.github.com/ober/6692833
function pagerduty(incident_key, msg)
   local http = require "socket.http"
   local ltn12 = require "ltn12"

    local reqbody = {
       ["service_key"]  = read_config("apikey"),
       ["incident_key"] = incident_key,
       ["event_type"]   = "trigger",
       ["description"]  = msg
    }

    local respbody = {} -- for the response body
    reqbody = json.encode(reqbody)

    local result, respcode, respheaders, respstatus = http.request {
       method = "POST",
       url = "https://events.pagerduty.com/generic/2010-04-15/create_event.json",
       source = ltn12.source.string(reqbody),
       headers = {
          ["content-type"] = "application/json",
          ["content-length"] = tostring(#reqbody)
       },
       sink = ltn12.sink.table(respbody)
    }

    -- We should check for respcode
    return respbody
end

function process_message() 
  pd_resp = pagerduty("test", read_message("Payload"))

  if pd_resp["status"] ~= "success" then
    return -1
  end

  -- TODO Inject a new message into the router that indicates we paged someone
  return 0
end

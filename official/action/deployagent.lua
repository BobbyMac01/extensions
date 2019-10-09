--[[
	Infocyte Extension
	Name: Deploy Infocyte Agent
	Type: Action
	Description: Installs Infocyte agents on Windows, Linux, or OSX
	Author: Infocyte
	Created: 9-19-2019
	Updated: 9-19-2019 (Gerritz)

]]--

----------------------------------------------------
-- SECTION 1: Variables
----------------------------------------------------
OS = hunt.env.os()
myinstance = hunt.net.api() -- "alpo1.infocyte.com"
computername = hunt.env.hostname()

installpath = [[C:\Program Files\Infocyte\Agent\agent.windows.exe]]
agentDestination = os.getenv("TEMP").."\\icagent.exe"

----------------------------------------------------
-- SECTION 2: Functions
----------------------------------------------------


----------------------------------------------------
-- SECTION 3: Actions
----------------------------------------------------

-- TODO: Check for Agent
agentinstalled = false
if agentinstalled then
  log("Infocyte Agent is already installed")
  exit()
else
  -- Install Infocyte Agent
  if string.find(OS, "windows") then
    agenturl = "https://s3.us-east-2.amazonaws.com/infocyte-support/executables/agent.windows.exe"

  elseif string.find(OS, "osx") or string.find(OS, "bsd") then
    agenturl = "https://s3.us-east-2.amazonaws.com/infocyte-support/executables/agent.osx.exe"

  else
  	-- TO DO: Assume linux-type OS
    agenturl = "https://s3.us-east-2.amazonaws.com/infocyte-support/executables/agent.linux.exe"
  end
  -- Download agent
  assert(hunt.web.download_file(agenturl, agentDestination, true))

  -- Install agent
  result = os.execute(agentDestination.." --install --quiet --url "..myinstanceurl.." --key "..regkey)
  if not result then
    hunt.log("Error: Agent failed to install. [Error: "..result.."]")
    exit()
  end
end

----------------------------------------------------
-- SECTION 4: Output
----------------------------------------------------
log("Infocyte Agent has been installed successfully")

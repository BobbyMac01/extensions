--[[
	Infocyte Extention
	Name: Uninstall Application - ITunes Example
	Type: Action
	Description: Looks to the registry to grab to the path to uninstall a general application 
	Author: Virgin Mobile UAE
	Created: December 24, 2019
	Updated: December 24, 2019
--]]

-- /*****************************************************
--  * Section 1: Inputs (Variables)
--  ****************************************************/

regUninstallKeyPath = "\\registry\\machine\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall" 
reg32BitUNinstallKeyPath = "\\registry\\machine\\SOFTWARE\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall"

-- /*****************************************************
--  * Section 2: Functions
--  ****************************************************/

function getUninstallRegKey(regPath, SubKeyDisplayNameValue)

	subkeys = hunt.registry.list_keys(regPath)

	-- make sure there are subkeys
	if subkeys then

		for skName,skValue in pairs(subkeys) do

			subKeyValues = hunt.registry.list_values(regPath .. "\\" .. skValue)

			for skvName, skvValue in pairs(subKeyValues) do
				if skvName == "DisplayName" then 
					if skvValue == SubKeyDisplayNameValue then 
						return skValue
					end
				end
			end
		end 

	end

	return nil
   
end

function checkAllUninstallRegLocations(SubKeyDisplayNameValue)

   returnVal = getUninstallRegKey(regUninstallKeyPath, SubKeyDisplayNameValue)

   -- if didn't find, look in 32-bit registry
   if returnVal == nil then
      returnVal = getUninstallRegKey(reg32BitUNinstallKeyPath, SubKeyDisplayNameValue)
   end

   return returnVal

end

function uninstall(SubKeyDisplayNameValue)

	uninstallKey = checkAllUninstallRegLocations(SubKeyDisplayNameValue)

	if uninstallKey then	-- found a value that isn't nil

		tmpUninstalCommand = "msiexec.exe  /norestart /X " .. uninstallKey .. " /qn"
		os.execute(tmpUninstalCommand)
		--os.sleep(60) -- don't think this is actually needed, but keeping it in here for later (just incase)
		hunt.log ("Uninstalled " .. SubKeyDisplayNameValue .. " with command: " .. tmpUninstalCommand)
		
	else
		hunt.log ("Failed to find uninstall key for " .. SubKeyDisplayNameValue)
	end

end

-- /*****************************************************
--  * Section 3: Actions
--  ****************************************************/

host_info = hunt.env.host_info()
osversion = host_info:os()
hunt.debug("Starting Uninstall LUA extention. Hostname: " .. host_info:hostname() .. ", Domain: " .. host_info:domain() .. ", OS: " .. host_info:os() .. ", Architecture: " .. host_info:arch())

-- All OS Specific Code needs to be executed in its' own section

-- Windows Code
if hunt.env.is_windows() then

	-- example of uninstall (note, display name is from registry keys)
	uninstall("iTunes")
	uninstall("SQL Server Management Studio")

-- Non Combatible OS
else
    hunt.warn("Not a compatible operating system for this extension [" .. host_info:os() .. "]")

end

hunt.log("Result: Uninstall Lua extention successfully executed on " .. host_info:hostname())
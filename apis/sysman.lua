--[[ System management API ]]
--[[ Contains various features for controlling the system - i.e. boot scripts ]]

local args = {...}

if #args > 0 then
	if args[1] == "install" then
		print(package.installed.sysman.apemanzilla.files[1].path)
	elseif args[1] == "remove" then

	end
else
	-- load API
end
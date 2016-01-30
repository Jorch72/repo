--[[ System management API ]]
--[[ Contains various features for controlling the system - i.e. boot scripts ]]

local args = {...}

if #args > 0 then
	if args[1] == "install" then
		local path = fs.combine(package.installRoot, "usr/apis")
		print(path)
		print(fs.exists(path))
	elseif args[1] == "remove" then

	end
else
	-- load API
end
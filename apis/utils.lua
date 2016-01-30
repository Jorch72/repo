--[[ General utilities ]]

local args = {...}

local startup_loader = "os.loadAPI 'usr/apis/utils'\n"

if #args > 0 then
	if args[1] == "install" then
		-- add line to automatically load at startup
		local f = fs.open("startup","r")
		local fdata = f.readAll()
		f.close()
		if not fdata:find(startup_loader) then
			local f = fs.open("startup","w")
			f.write(startup_loader .. fdata)
			f.close()
		end
	elseif args[1] == "remove" then
		-- remove line from startup
		local f = fs.open("startup","r")
		local fdata = f.readAll()
		f.close()
		fdata = fdata:gsub(startup_loader,"")
		local f = fs.open("startup","w")
		f.write(fdata)
		f.close()
	end
else
	function expect(got, argtype, num, optional)
		-- got : the argument that was given
		-- argtype : the type of argument expected
		-- num : the argument number
		-- optional : whether the argument can be nil
		if (type(got) == argtype or (got == nil and optional)) then
			return true
		end
		error(string.format("expected %s, got %s for arg %d", argtype, type(got), num), 3)
	end

	function resolve(path, base)
		expect(path, "string", 1)
		expect(base, "string", 2)
		local s = string.sub( path, 1, 1 )
		if s == "/" or s == "\\" then
			return fs.combine( "", path )
		else
			return fs.combine( base, path )
		end
	end

	-- paths to search in for APIs
	api_paths = {
		"/usr/apis"
	}

	-- extensions to try for APIs
	api_exts = {
		".lua",
		""
	}

	function locateAPI(apiname)
		for _,v in ipairs(api_exts) do
			local n = apiname .. v
			for _,v in ipairs(api_paths) do
				local n = resolve(n, v)
				if fs.exists(n) then
					return n
				end
			end
		end
	end

	function loadAPI(apiname, legacy)
		-- if legacy is true, then the API will be loaded as if loaded with os.loadAPI - into the global table
		-- if legacy is false, then the API will be loaded and returned.
		expect(apiname, "string", 1)
		expect(legacy, "boolean", 2, true)
		local path = locateAPI(apiname)
		if not path then
			printError(string.format("failed to locate api %s", apiname))
			return false
		end
		local e = {}
		setmetatable(e, {__index = _G})
		local f = fs.open(path, "r")
		local data = f.readAll()
		f.close()
		local api_func, err = load(data, apiname, nil, e)
		if api_func then
			local ok, err = pcall(api_func)
			if not ok then
				printError(err)
				return false
			else
				local out = {}
				for k,v in pairs(e) do
					if k ~= "_ENV" then
						out[k] = v
					end
				end
				if legacy then
					_G[apiname] = out
					return true
				else
					return out
				end
			end
		else
			printError(err)
			return false
		end
	end
end
local skynet = require "skynet"

skynet.start(function()
	assert(skynet.launch("logger", skynet.getenv "logger"))

	local standalone = skynet.getenv "standalone"
	local harbor_id = tonumber(skynet.getenv "harbor")
	if harbor_id == 0 then
		assert(standalone ==  nil)
		standalone = true
		skynet.setenv("standalone", "true")
		assert(skynet.launch("dummy"))
	else
		local master_addr = skynet.getenv "master"

		if standalone then
			assert(skynet.launch("master", master_addr))
		end

		local local_addr = skynet.getenv "address"

		assert(skynet.launch("harbor",master_addr, local_addr, harbor_id))
	end

	local launcher = assert(skynet.launch("snlua","launcher"))
	skynet.name(".launcher", launcher)

	if standalone then
		local datacenter = assert(skynet.newservice "datacenterd")
		skynet.name("DATACENTER", datacenter)
	end
	assert(skynet.newservice "service_mgr")
	assert(skynet.newservice(skynet.getenv "start" or "main"))
	skynet.exit()
end)

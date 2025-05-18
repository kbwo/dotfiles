return {
	settings = {
		documentFormatting = false,
		javascript = { suggest = { completeFunctionCalls = true } },
		typescript = { suggest = { completeFunctionCalls = true } },
	},
	root_dir = function(path)
		local marker = require("climbdir.marker")
		-- Determine the root directory based on the presence of package.json or node_modules
		return require("climbdir").climb(path,
			marker.one_of(marker.has_readable_file("package.json"), marker.has_directory("node_modules")), {
				-- Stop the plugin if any of the specified files/folders are found
				halt = marker.one_of(
					marker.has_readable_file("deno.json"),
					marker.has_readable_file("deno.jsonc"),
					marker.has_readable_file("import_map.json"),
					marker.has_directory("denops")
				),
			})
	end,
}

-- return ts_opts

return {
	single_file_support = true,
	root_dir = function(bufnr, callback)
		local path = vim.fs.dirname(vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr)))

		-- Check if deno.json exists in the path or any parent directory
		local deno_files = vim.fs.find({
			"deno.json",
			"deno.jsonc",
		}, {
			upward = true,
			path = path,
		})

		-- Only proceed if no deno files are found
		if #deno_files == 0 then
			local found_dirs = vim.fs.find({
				".git",
				"package.json",
				"node_modules",
			}, {
				upward = true,
				path = path,
			})
			if #found_dirs > 0 then
				return callback(vim.fs.dirname(found_dirs[1]))
			end
		end
	end,
}

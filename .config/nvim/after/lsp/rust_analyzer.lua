return {
	["rust-analyzer"] = {
		cargo = {
			features = "all",
			buildScripts = {
				enable = true,
			},
		},
		-- enable clippy on save
		checkOnSave = {
			command = "clippy",
		},
		check = {
			command = "clippy",
		},
		diagnostics = {
			disabled = {
				"unresolved-proc-macro",
				"inactive-code",
			},
		},
	},
}

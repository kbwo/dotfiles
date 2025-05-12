local capabilities = vim.tbl_deep_extend("force", require("cmp_nvim_lsp").default_capabilities(), {
	workspace = {
		didChangeWatchedFiles = {
			dynamicRegistration = true,
		},
	},
})

return {
	capabilities = capabilities,
	settings = {
		basedpyright = {
			analysis = {
				diagnosticSeverityOverrides = {
					reportMissingTypeStubs = "none",
				},
			},
		},
	},
}

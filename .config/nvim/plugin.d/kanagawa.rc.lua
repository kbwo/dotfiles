require("kanagawa").setup({
	theme = "wave", -- Load "wave" theme when 'background' option is not set
	background = { -- map the value of 'background' option to a theme
		dark = "wave", -- try "dragon" !
		light = "lotus",
	},
	colors = {
		palette = {
			oniViolet = "#B6A7CE",
			oniViolet2 = "#E5E3ED",
			samuraiRed = "#f7768e",
			autumnRed = "#CE6466",
		},
	},
	overrides = function(colors)
		return {
			Visual = { bg = "#5a6773" },
			CursorLine = { bg = "#3E4452", bold = true },
			Search = { fg = "#FFFFFF", bg = "#b26e29", bold = true },
			CurSearch = { fg = "#FFFFFF", bg = "#b26e29", bold = true },
			NonText = { bg = "NONE" },
			SpecialKey = { bg = "NONE" },
			EndOfBuffer = { bg = "NONE" },
			Comment = { fg = "gray70" },
			rustCommentLineDoc = { fg = "gray70" },
			CocMenuSel = { link = "PmenuSel" },
			HopNextKey = { fg = "#ff9dcd", bold = true },
			FgCocErrorFloatBgCocFloating = { fg = "#F7768E" },
			Error = { fg = "#F7768E" },
			ErrorMsg = { fg = "#F7768E" },
			PreProc = { fg = "#FF9E64" },
			DiagnosticError = { fg = "#F7768E" },
			DiagnosticSignError = { fg = "#F7768E" },
			DiagnosticUnderlineError = { fg = "#F7768E" },
			DiagnosticFloatingError = { fg = "#F7768E" },
			NvimInternalError = { fg = "#F7768E" },
			healthError = { fg = "#F7768E" },
			DapUIWatchesError = { fg = "#F7768E" },
			FloatShadowThrough = { bold = true, fg = "#938aa9", bg = "#16161d" },
			FloatShadow = { bold = true, fg = "#938aa9", bg = "#16161d" },
			TabLine = { bg = "#1E1E2E", fg = "#7F848E", sp = "#3E4451" },
			TabLineSel = { bg = "#F7768E", fg = "#3E4452", sp = "#F7768E" },
			TabLineFill = { bg = "#21252B", fg = "#7F848E", sp = "#21252B" },
			LspInlayHint = { fg = "#8f784a" },
		}
	end,
})
require("kanagawa").load()

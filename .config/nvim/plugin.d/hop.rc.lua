require("hop").setup()
vim.keymap.set("n", "<Leader>f", function()
	local hop = require("hop")
	-- 漢字 / カタカナ / 英数字それぞれの連なりの先頭を候補にする。
	-- ひらがなは候補から外す: 助詞や送り仮名まで拾うと候補が倍増し、
	-- ラベルが 2 桁化して本文を読めなくする割に足場としての価値が低い。
	-- カタカナ類には長音符「ー」を含める（含めないと「アップロード」が 2 候補に割れる）。
	local re = vim.regex("\\v<\\w+|[一-龥]+|[ァ-ヶー]+")
	hop.hint_with_regex({
		oneshot = false,
		match = function(s)
			return re:match_str(s)
		end,
	}, hop.opts)
end, {})
-- vim.api.nvim_set_keymap("n", "<Leader>f", "<cmd>HopAnywhere<cr>", {})
vim.api.nvim_set_keymap("v", "<Leader>f", "<cmd>lua require('hop')[vim.fn.mode() == 'V' and 'hint_lines' or 'hint_words']({extend_visual = true})<cr>", {})
vim.api.nvim_set_keymap("n", "<c-w>f", ":HopLine<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<c-w>f", "<cmd>lua require'hop'.hint_lines({extend_visual = true})<cr>", { noremap = true, silent = true })

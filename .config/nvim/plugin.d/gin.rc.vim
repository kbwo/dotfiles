nmap gns :GinStatus<CR>
nmap gnc :Gin commit<CR>
<<<<<<< HEAD
nmap gnb :GinBranch<CR>
=======
nmap gnb :GinBranch ++opener=botright\ vsplit<CR>
>>>>>>> 5cef9dc904c462069f607030f851ebec7a15a42f
nmap gnh :Gin checkout -b
nmap gnps :Gin push
nmap gnpl :Gin pull<CR>
nmap gnl :GinLog --oneline --graph<CR>

function! CurrentFileLog() abort
  execute 'GinLog --graph -p -- ' . expand('%:p')
endfunction

nmap gncl :call CurrentFileLog()<CR>

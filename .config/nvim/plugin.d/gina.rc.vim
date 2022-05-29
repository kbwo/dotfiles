nmap gns :Gina status --opener=vsplit<CR>
nmap gnc :Gina commit --opener=split<CR>
nmap gnb :Gina branch --opener=vsplit<CR>
nmap gnh :Gina checkout -b
nmap gnps :Gina push
nmap gnpl :Gina pull<CR>
nmap gnl :Gina log --oneline --graph<CR>
let g:gina#command#blame#formatter#format = '%au: %su%= on %ti %ma%in'

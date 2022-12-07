" Title: AL Neovim
" Description: A plugin that allows your Neovim installation to interact with
" the AL language server.
" Last Change: 3 December 2022
" Maintainer: Gustav Utke Kauman <hello@kauman.dev>

if exists("g:loaded_alneovim")
	finish " avoid loading plugin twice
endif
let g:loaded_alneovim = 1

" Set filetype for *.al files
au BufReadPost *.al set filetype=al

command! ALNeovim lua require("al-neovim.al-lsp").al_neovim()

au BufReadPost * ALNeovim


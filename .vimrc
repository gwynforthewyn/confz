colorscheme desert

" set word wrap at 72 characters if we're editing a git commit
if expand('%t') =~ 'COMMIT_EDITMSG$'
    set tw=72
    set colorcolumn=73
endif

" Install Plug
" https://github.com/junegunn/vim-plug
if !isdirectory($HOME.'/.vim/autoload/plug.vim')
  call system('curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
endif

call plug#begin('~/.vim/plugged')
Plug 'https://github.com/scrooloose/nerdtree.git'
Plug 'https://github.com/Xuyuanp/nerdtree-git-plugin.git'
call plug#end()

" Turn off header banner when using 'explore'
let g:netrw_banner = 0

" Start up NERDTree by default
" autocmd vimenter * NERDTree
function! ToggleNERDTree()
  if exists("b:NERDTree")
    NERDTreeToggle
  else
    NERDTreeFocus
  endif
endfunction

map <C-n> :call ToggleNERDTree()<cr>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" let nerdtree show hidden files
let NERDTreeShowHidden=1

" <Ctrl-l> redraws the screen and removes any search highlighting.
nnoremap <silent> <C-l> :nohl<CR><C-l>

" .vimrc — sensible vim defaults

" ── plugins (vim-plug) ────────────────────────────────────────────────────────
" Auto-install vim-plug if not present
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

if filereadable(expand('~/.vim/autoload/plug.vim'))
  call plug#begin('~/.vim/plugged')
    Plug 'tpope/vim-sensible'          " sensible defaults
    Plug 'tpope/vim-commentary'        " gc to comment
    Plug 'tpope/vim-surround'          " cs, ds, ys motions
    Plug 'tpope/vim-fugitive'          " git integration
    Plug 'airblade/vim-gitgutter'      " git diff in gutter
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'            " fzf in vim
    Plug 'itchyny/lightline.vim'       " lightweight statusline
    Plug 'morhetz/gruvbox'             " colorscheme
  call plug#end()
endif

" ── appearance ────────────────────────────────────────────────────────────────
set termguicolors
set background=dark
silent! colorscheme gruvbox

syntax enable
set number relativenumber       " hybrid line numbers
set cursorline                  " highlight current line
set signcolumn=yes              " always show sign column
set colorcolumn=80,120          " column rulers
set showmatch                   " highlight matching brackets

" ── editing ───────────────────────────────────────────────────────────────────
set expandtab                   " spaces over tabs
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set smartindent

set wrap
set linebreak                   " wrap at word boundaries
set scrolloff=8                 " keep 8 lines above/below cursor
set sidescrolloff=8

" ── search ────────────────────────────────────────────────────────────────────
set ignorecase
set smartcase                   " case-sensitive if uppercase used
set incsearch
set hlsearch
nnoremap <Esc> :noh<CR><Esc>   " clear search highlight with Esc

" ── files ─────────────────────────────────────────────────────────────────────
set nobackup
set noswapfile
set undofile
set undodir=$HOME/.vim/undo
if !isdirectory($HOME . '/.vim/undo')
  call mkdir($HOME . '/.vim/undo', 'p')
endif

" ── misc ──────────────────────────────────────────────────────────────────────
set hidden                      " allow unsaved buffers
set clipboard=unnamedplus       " use system clipboard
set mouse=a
set lazyredraw
set updatetime=300
set timeoutlen=500

" ── key mappings ──────────────────────────────────────────────────────────────
let mapleader = " "

" faster save/quit
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :x<CR>

" split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" fzf
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>g :Rg<CR>

" move lines
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

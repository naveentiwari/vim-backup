" Enable backup and undo in vim

if exists('g:loaded_vim_backup')
    finish
endif
let g:loaded_vim_backup = 1

if !exists("g:VimBackupDir")
    let g:VimBackupDir = '~/.local/vimfiles'
endif
let g:VimBackupDir = expand(g:VimBackupDir)

if !exists("g:VimBackupSlashSubstitute")
    let g:VimBackupSlashSubstitute = "%"
endif

if !exists("g:VimBackupRecentOnly")
    let g:VimBackupRecentOnly = 0
endif

if !exists("g:VimBackupHourly")
    let g:VimBackupHourly = 0
endif

if !exists("g:VimBackupMinute")
    let g:VimBackupMinute = 10
endif

if !exists("g:VimBackupNoUndofileConfigure")
    set undofile
    execute 'silent !mkdir -p ' . g:VimBackupDir . '/undo '
    let &undodir=g:VimBackupDir . '/undo//' " version 7.3+
endif

if !exists("g:VimBackupNoSwapConfigure")
    execute 'silent !mkdir -p ' . g:VimBackupDir . '/swap '
    let &directory=g:VimBackupDir . '/swap'
endif

set backup
execute 'silent !mkdir -p ' . g:VimBackupDir . '/backup '
let &backupdir=g:VimBackupDir . '/backup'

function! s:GetCurrentFilePathPart()
    let curpath=expand('%:p:h')
    if len(curpath) < 1
        curpath = '.'
    endif
    return substitute(curpath, '/', g:VimBackupSlashSubstitute, 'g')
endfunction

function! s:GetTimePart()
    if (g:VimBackupRecentOnly)
        return 'recent'
    endif
    if (g:VimBackupHourly)
        return strftime("%y_%m_%d_%H")
    endif
    " get local time, this is in seconds so divide by 60 to get minutes
    " take modulo to get minutes past last hour
    let curMinute   = (localtime() / 60) % 60
    let minuteStamp = curMinute + g:VimBackupMinute - (curMinute % g:VimBackupMinute)

    return strftime("%y_%m_%d_%H_") . string(minuteStamp)
endfunction


function! s:BackupExtnUpdate()
    let bkup_extn='set backupext=_' . s:GetCurrentFilePathPart() . '_' . s:GetTimePart()
    execute bkup_extn
endfunction

augroup extnupdate
au BufWritePre * :call s:BackupExtnUpdate()
augroup END


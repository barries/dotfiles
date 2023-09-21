
-- vim-mark config
--
-- This must be done before vim-mark is loaded
--
-- vim-mark maps a fair number of sequences, including \r, which
-- I map for replace, and # and *, which make search on marks
-- not work intuitively for me.
--
-- Its \n (clear marks) has a caveat that repeating \m doesn't
-- have, and repeating \m to clear the highlighted mark is all
-- I need.

vim.g.mw_no_mappings               = 1   -- 1: Tell mark.vim not to install global mappings
vim.g.mwHistAdd                    = ""  -- "": Don"t auto add to search or input histories
vim.g.mwDefaultHighlightingPalette = "extended"

vim.keymap.set({"n", "x"}, "<Leader>m", "<Plug>MarkSet");

-- lazy.nvim config

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath);

local plugins = {
    "danro/rename.vim",
    "godlygeek/tabular",
    "inkarkat/vim-ingo-library",
    "inkarkat/vim-mark", -- sets maps on \r *after* .vimrc exit, see VimEnter_Initialize()
    "kana/vim-submode",
    "nvim-treesitter/nvim-treesitter",
    "mbbill/undotree",
    "junegunn/fzf",
    -- "vim-scripts/Align"
};

local lazy_opts = {
};

require("lazy").setup(plugins, lazy_opts);

-- Personal config

-- use existing directories for vim compatibility
vim.opt.runtimepath:prepend("~/.vim");
vim.opt.runtimepath:append("~/.vim/after");

vim.cmd.colorscheme("barries");

if vim.env[TMUX] and #vim.env.TMUX then
    vim.env.DISPLAY = ""; -- Prevent slowness when running in TMUX, which exports its startup DISPLAY TODO: review this and see why I added it.
end

vim.cmd [[source ~/.vimrc]];

require'nvim-treesitter.configs'.setup{
  -- commenting out 2021-02-13, to avoid "string required" error after neovim update: ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  highlight = {
    enable = true,              -- false will disable the whole extension
    -- disable = { "c", "rust" },  -- list of language that will be disabled
  },
  incremental_selection = {
    enable = true,
  },
}

local parsers  = require'nvim-treesitter.parsers'
local queries  = require'nvim-treesitter.query'
local ts_utils = require'nvim-treesitter.ts_utils'
local utils    = require'nvim-treesitter.utils'
local hlmap    = vim.treesitter.highlighter.hl_map

function show_hl_captures()
  local bufnr = vim.api.nvim_get_current_buf()
  local lang = parsers.get_buf_lang(bufnr)
  local hl_captures = vim.tbl_keys(hlmap)

  if not lang then return end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1

  local matches = {}
  for m in queries.iter_group_results(bufnr, 'highlights') do
    for _, c in pairs(hl_captures) do
      local node = utils.get_at_path(m, c..'.node')
      if node and ts_utils.is_in_node_range(node, row, col) then
        table.insert(matches, '@'..c..' -> '..hlmap[c])
      end
    end
  end
  if #matches == 0 then
    matches = {"No tree-sitter matches found!"}
  end
  local bnr, wnr = vim.lsp.util.open_floating_preview(matches, "treesitter-hl-captures", { pad_left = 1, pad_top = 0, pad_right = 1, pad_bottom = 0 })
  vim.api.nvim_win_set_option(wnr, 'winhl', 'Normal:NormalFloat')
end

local function compare_row_col(arow, acol, brow, bcol)
    if     arow < brow then return -1
    elseif arow > brow then return  1
    elseif acol < bcol then return -1
    elseif acol > bcol then return  1
    else                    return  0
    end
end

local function get_first_tree_root()
    local bufnr  = vim.api.nvim_get_current_buf()
    local lang   = parsers.get_buf_lang(bufnr)
    local parser = vim.treesitter.get_parser()
    local trees  = parser:parse()
    local tree   = trees[1]
    return tree:root()
end

function get_visual_mode_range()
    local _, vrow, vcol = unpack(vim.fn.getpos("v")) -- v: "visual mode"
    local _, crow, ccol = unpack(vim.fn.getpos(".")) -- c: "cursor"

    return vrow, vcol, crow, ccol
end

function normalize_visual_range(vrow, vcol, crow, ccol)
    local is_reversed = compare_row_col(vrow, vcol, crow, ccol) > 0
    if is_reversed then
        vrow, vcol, crow, ccol = crow, ccol, vrow, vcol
    end

    return vrow, vcol, crow, ccol
end

local function get_node_for_visual_range(vrow, vcol, crow, ccol)
    if not vim.fn.mode():match("[vV]") then
        vim.cmd('normal! gv')
    end

    local mode = vim.fn.mode()
    if mode ~= 'v' then
        vim.cmd('normal! v')
    end
    local vrow, vcol, crow, ccol = get_visual_mode_range()

    local is_reversed = compare_row_col(vrow, vcol, crow, ccol) > 0
    if is_reversed then
        vrow, vcol, crow, ccol = crow, ccol, vrow, vcol
    end

    vrow = vrow - 1
    vcol = vcol - 1
    crow = crow - 1

    if mode ~= 'v' then
        vim.cmd('normal! ' .. mode)
    end

    return get_first_tree_root():descendant_for_range(vrow, vcol, crow, ccol)
end

function enumerate_visual_nodes(node, indent)
    if node == nil then
        node = get_node_for_visual_range()
    end

    vim.cmd('normal! \\<Esc>')

    if indent == nil then
        indent = "  "
    end

    local next_indent = indent .. "  "
    for child in node:iter_children() do
        print(indent .. child:type())
        enumerate_visual_nodes(child, next_indent)
    end
end

function get_cursor()
    local c = vim.api.nvim_win_get_cursor(0)
    return c[1], c[2]
end

function get_char()
    local _, col = get_cursor()
    return vim.api.nvim_get_current_line():sub(col + 1, col + 1)
end

function get_visual_range_lines(mode, srow, scol, erow, ecol)
    local lines = vim.fn.getline(srow, erow);

    if #lines > 0 then
        if mode == "v" then
            local last_line_at_eol = (#lines[#lines] == ecol)

            lines[#lines] = lines[#lines]:sub(1, ecol)
            lines[1] = lines[1]:sub(scol)
            for i in ipairs(lines) do
                if i < #lines or last_line_at_eol then
                    lines[i] = lines[i] .. "\n"
                end
            end
        elseif mode == "" then
            for i in ipairs(lines) do
                lines[i] = lines[i]:sub(1, ecol)
                lines[i] = lines[i]:sub(scol) .. "\n"
            end
        end
    end

    return lines
end

function get_visual_range_string(...)
    return vim.fn.json_encode(table.concat(get_visual_range_lines(...)))
end

local grow_visual_region_stack     = {};
local grow_visual_region_stack_pos = 0;

function grow_visual_region(is_visual_mode)
    if is_visual_mode then
        -- grow_visual_region() is called using ex command line, which resets vim to normal mode; re-enter visual mode
        vim.cmd('normal! gv')
    else
        local crow, ccol = get_cursor()
        grow_visual_region_stack = {
            {'n', crow, ccol + 1, crow, ccol + 1}
        };
        grow_visual_region_stack_pos = 1
        --print(grow_visual_region_stack_pos, vim.inspect(grow_visual_region_stack))

        vim.cmd('normal! v')
    end

    --print(grow_visual_region_stack_pos, #grow_visual_region_stack)
    if grow_visual_region_stack_pos < #grow_visual_region_stack then
        grow_visual_region_stack_pos = grow_visual_region_stack_pos + 1
        set_visual_region(unpack(grow_visual_region_stack[grow_visual_region_stack_pos]))
        --print(grow_visual_region_stack_pos, vim.inspect(grow_visual_region_stack))
        return
    end

    local mode = vim.fn.visualmode()
    local vrow, vcol, crow, ccol = get_visual_mode_range()
    local srow, scol, erow, ecol;

    vrow, vcol, crow, ccol = normalize_visual_range(vrow, vcol, crow, ccol)

    local trace = function(s)
    end

    if mode == 'v' and #grow_visual_region_stack == 1 then
        if vrow == crow and vcol == ccol then
            local char = get_char()
            if char == ' ' or char == '\t' or char == '' then -- '' is eol
                trace('space')
                vim.cmd('normal! wh')
                srow, scol = get_cursor()

                vim.cmd('normal! oB')
                if get_char() ~= '' then
                    vim.cmd('normal! El')
                end
                if get_char() == '' then
                    vim.cmd('normal! l')
                end
            elseif char:match('[%w_]') then
                trace('word')
                vim.cmd('normal! iw')
                srow, scol = get_cursor()

                vim.cmd('normal! o')
            elseif char:match("[(){}[%]<>]") then
                trace('block' .. char)
                vim.cmd('normal! a' .. char)
                srow, scol = get_cursor()
                vim.cmd('normal! o')
            elseif char == '"' or char == '\'' then
                trace('string')
                vim.cmd('normal! i' .. char)

                local sr, sc, er, ec = get_visual_mode_range()
                local is_single_char = (sr == er and sc == ec)
                if is_single_char then
                    srow, scol = get_cursor()
                else
                    vim.cmd('normal! l') -- wierdly, the l and h works with '' and "" because i" and i' leave the cursor on the first ' of empty strings
                    srow, scol = get_cursor()
                    vim.cmd('normal! oh')
                end
            else
                trace('punct')
                repeat ----
                    vim.cmd('normal! h')
                until get_char('.'):match("[%w_\"'(){}[%]<>%s]")
                vim.cmd('normal! l')
                srow, scol = get_cursor()
                repeat ----
                    vim.cmd('normal! l')
                until get_char('.'):match("[%w_\"'(){}[%]<>%s]")
                vim.cmd('normal! h')
            end
            if srow then
                erow, ecol = get_cursor()
                goto set_new_visual_range
            end
        end
    end

    do
        vrow = vrow - 1
        vcol = vcol - 1
        crow = crow - 1

        local root = get_first_tree_root()
        local node = root:descendant_for_range(vrow, vcol, crow, ccol)

        if node == root then
            if mode ~= "v" then
                vim.cmd("normal! " .. mode)
            end

            return
        end

        local iter_count = 0
        local select_node = true
        while iter_count < 100 do          -- prevent inf. loop; 100: big enough to not false positive
            iter_count = iter_count + 1

            if node == root then
                break
            end

            if select_node then
                -- See if we want to select just a few of node's children, like i( or i{, or grow a list one element at a time

                local first_child
                local second_child
                local last_child
                local second_last_child
                local last_was_comma_or_open = false
                local started_just_after_comma_or_open = false
                local list_element_growth_mode = false
                local aligned_selection_detector_state = "not_started" -- not_started, started, just_after, after, failed
                for child in node:iter_children() do
                    if first_child == nil then
                        first_child = child
                    elseif second_child == nil then
                        second_child = child
                    end

                    local type = child:type()

                    if list_element_growth_mode then
                        if type == "," then
                            _, _, erow, ecol = child:range()
                            select_node = false
                            break
                        elseif string.find(")]}>", type, nil, true) then -- true: turn off patterns
                            _, _, erow, ecol = last_child:range()
                            select_node = false
                            break
                        end
                    end

                    if aligned_selection_detector_state == "just_after" and type == "," then
                        if started_just_after_comma_or_open and type == "," then
                            _, _, erow, ecol = child:range()
                            select_node = false
                            break
                        end
                    end

                    if aligned_selection_detector_state == "not_started" then
                        local sr, sc = child:range()
                        if sr == srow and sc == scol then
                            aligned_selection_detector_state = "started"
                            started_just_after_comma_or_open = last_was_comma_or_open
                        end
                    end

                    if aligned_selection_detector_state == "started" then
                        local _, _, er, ec = child:range()
                        local cmp = compare_row_col(er, ec, erow, ecol)
                        if cmp == 0 then
                            aligned_selection_detector_state = "just_after"
                            if type == "," then
                                list_element_growth_mode = true
                            end
                        elseif cmp > 0 then
                            aligned_selection_detector_state = "failed"
                        end
                    elseif aligned_selection_detector_state == "just_after" then
                        aligned_selection_detector_state = "after"
                    end

                    last_was_comma_or_open = string.find(",({[<", type, nil, true) -- true: turn off patterns
                    second_last_child = last_child
                    last_child = child

                end

                if second_last_child ~= nil
                    and (
                           (first_child:type() == "(" and last_child:type() == ")")
                        or (first_child:type() == "{" and last_child:type() == "}")
                    )
                then
                    local sr, sc = second_child:range()
                    local _, _, er, ec = second_last_child:range()
                    if not (sr == srow and sc == scol and er == erow and ec == ecol) then
                        srow, scol, erow, ecol = sr, sc, er, ec
                        select_node = false
                    end
                end

                if select_node then
                    srow, scol, erow, ecol = node:range()
                    select_node = false
                end
            end

            if     compare_row_col(srow, scol, vrow, vcol) < 0
                or compare_row_col(erow, ecol, crow, ccol) > 0
            then
                break
            end

            local parent = node:parent()

            local use_parent = false

            if node:type() == "comment" then
                local saw_node = false
                local count = 0
                for child in parent:iter_children() do
                    if child == node then
                        saw_node = true
                    end
                    if child:type() == "comment" then
                        if count == 0 then
                            srow, scol = child:range()
                        end
                        count = count + 1
                        _, _, erow, ecol = child:range()
                    elseif saw_node then
                        use_parent = count == 1
                        break
                    else
                        count = 0
                    end
                end
            elseif node:type() == ";" or node:type() == "," then
                local prev_node;
                for child in parent:iter_children() do
                    if child == node then
                        if prev_node == nil then
                            goto tweak_and_set_new_visual_range;
                        end
                        srow, scol = prev_node:range()
                        break
                    end
                    prev_node = child
                end
            else
                use_parent = true
            end

            if use_parent then
                if parent == root then
                    goto tweak_and_set_new_visual_range; -- we almost *never* want to select the whole file
                end
                node = parent
                select_node = true

            end
        end
    end

    ::tweak_and_set_new_visual_range::

    srow = srow + 1
    erow = erow + 1
    ecol = ecol - 1

    ::set_new_visual_range::

    if compare_row_col(srow, scol, erow, ecol) > 0 then
        local tmp;
        tmp = srow; srow = erow; erow = tmp;
        tmp = scol; scol = ecol; ecol = tmp;
    end

    scol = scol + 1
    ecol = ecol + 1

    local is_line_mode = false
    if srow < erow then
        local first_line = vim.fn.getline(srow)
        local up_to_and_including_first_char = vim.fn.strcharpart(first_line, 0, scol)
        local is_first_non_whitespace = (string.match(up_to_and_including_first_char, "^[ \t]*[^ \t]$") ~= nil)

        local last_line = vim.fn.getline(erow)
        local last_char_and_after = vim.fn.strcharpart(last_line, ecol - 1)
        local is_last_non_whitespace = (string.match(last_char_and_after, "^[^ \t][ \t]*$") ~= nil)

        is_line_mode = is_first_non_whitespace and is_last_non_whitespace
    end

    mode = is_line_mode and 'V' or 'v';
    local undo_entry = {mode, srow, scol, erow, ecol};
    if table.concat(undo_entry, ",") ~= table.concat(grow_visual_region_stack[#grow_visual_region_stack], ",") then
        table.insert(grow_visual_region_stack, {mode, srow, scol, erow, ecol})
        grow_visual_region_stack_pos = #grow_visual_region_stack
        print(grow_visual_region_stack_pos, vim.inspect(grow_visual_region_stack))
    end

    set_visual_region(mode, normalize_visual_range(srow, scol, erow, ecol))
end

function set_visual_region(mode, srow, scol, erow, ecol)
    if mode == 'n' then
        if vim.fn.mode() ~= 'n' then
            vim.cmd('normal! <esc>')
        end
    else
        if vim.fn.mode() ~= 'v' then
            vim.cmd('normal v')
        end
    end

    -- use '. and :normal o because passing '< and '> marks could _may_ result in swapping them (see manual)

    vim.fn.setpos('.', { 0, srow, scol, 0 })

    if mode ~= 'n' then
        vim.cmd('normal! o')
        vim.fn.setpos('.', { 0, erow, ecol, 0 })

        if mode ~= 'v' then
            vim.cmd('normal! ' .. mode)
        end
    end
end

function undo_grow_visual_region()
    if grow_visual_region_stack_pos > 0 then
        grow_visual_region_stack_pos = grow_visual_region_stack_pos - 1
        if grow_visual_region_stack_pos == 0 then
            if vim.fn.mode() ~= 'n' then
                vim.cmd('normal: <esc>')
            end
        else
            print(grow_visual_region_stack_pos, vim.inspect(grow_visual_region_stack))
            set_visual_region(unpack(grow_visual_region_stack[grow_visual_region_stack_pos]))
        end
    end
end


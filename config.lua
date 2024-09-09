-- Nixvim's internal module table
-- Can be used to share code throughout init.lua
local _M = {}

-- Ignore the user lua configuration
vim.opt.runtimepath:remove(vim.fn.stdpath("config")) -- ~/.config/nvim
vim.opt.runtimepath:remove(vim.fn.stdpath("config") .. "/after") -- ~/.config/nvim/after
vim.opt.runtimepath:remove(vim.fn.stdpath("data") .. "/site") -- ~/.local/share/nvim/site

-- Set up globals {{{
do
    local nixvim_globals = {
        colorizing_enabled = 1,
        disable_autoformat = false,
        disable_diagnostics = false,
        dotnet_build_project = function()
            local default_path = vim.fn.getcwd() .. "/"

            if vim.g["dotnet_last_proj_path"] ~= nil then
                default_path = vim.g["dotnet_last_proj_path"]
            end

            local path = vim.fn.input("Path to your *proj file", default_path, "file")

            vim.g["dotnet_last_proj_path"] = path

            local cmd = "dotnet build -c Debug " .. path .. " > /dev/null"

            print("")
            print("Cmd to execute: " .. cmd)

            local f = os.execute(cmd)

            if f == 0 then
                print("\nBuild: ✔️ ")
            else
                print("\nBuild: ❌ (code: " .. f .. ")")
            end
        end,
        dotnet_get_dll_path = function()
            local request = function()
                return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/", "file")
            end

            if vim.g["dotnet_last_dll_path"] == nil then
                vim.g["dotnet_last_dll_path"] = request()
            else
                if
                    vim.fn.confirm(
                        "Do you want to change the path to dll?\n" .. vim.g["dotnet_last_dll_path"],
                        "&yes\n&no",
                        2
                    ) == 1
                then
                    vim.g["dotnet_last_dll_path"] = request()
                end
            end

            return vim.g["dotnet_last_dll_path"]
        end,
        firenvim_config = {
            localSettings = {
                [".*"] = {
                    cmdline = "neovim",
                    content = "text",
                    priority = 0,
                    selector = "textarea",
                    takeover = "never",
                },
            },
        },
        first_buffer_opened = false,
        loaded_perl_provider = 0,
        loaded_python_provider = 0,
        loaded_ruby_provider = 0,
        mapleader = " ",
        maplocalleader = " ",
        mkdp_auto_close = 0,
        mkdp_theme = "dark",
        rustaceanvim = {
            dap = { autoloadConfigurations = true },
            server = {
                default_settings = {
                    ["rust-analyzer"] = {
                        cargo = { buildScripts = { enable = true }, features = "all" },
                        check = { command = "clippy", features = "all" },
                        checkOnSave = true,
                        diagnostics = { enable = true, styleLints = { enable = true } },
                        files = { excludeDirs = { ".cargo", ".direnv", ".git", "node_modules", "target" } },
                        inlayHints = {
                            bindingModeHints = { enable = true },
                            closureReturnTypeHints = { enable = "always" },
                            closureStyle = "rust_analyzer",
                            discriminantHints = { enable = "always" },
                            expressionAdjustmentHints = { enable = "always" },
                            implicitDrops = { enable = true },
                            lifetimeElisionHints = { enable = "always" },
                            rangeExclusiveHints = { enable = true },
                        },
                        procMacro = { enable = true },
                        rustc = { source = "discover" },
                    },
                },
                on_attach = function(client, bufnr)
                    return _M.lspOnAttach(client, bufnr)
                end,
            },
        },
        spell_enabled = true,
        undotree_CursorLine = true,
        undotree_DiffAutoOpen = true,
        undotree_DiffCommand = "diff",
        undotree_DiffpanelHeight = 10,
        undotree_HelpLine = true,
        undotree_HighlightChangedText = true,
        undotree_HighlightChangedWithSign = true,
        undotree_HighlightSyntaxAdd = "DiffAdd",
        undotree_HighlightSyntaxChange = "DiffChange",
        undotree_HighlightSyntaxDel = "DiffDelete",
        undotree_RelativeTimestamp = true,
        undotree_SetFocusWhenToggle = true,
        undotree_ShortIndicators = false,
        undotree_TreeNodeShape = "*",
        undotree_TreeReturnShape = "\\",
        undotree_TreeSplitShape = "/",
        undotree_TreeVertShape = "|",
    }

    for k, v in pairs(nixvim_globals) do
        vim.g[k] = v
    end
end
-- }}}

-- Set up options {{{
do
    local nixvim_options = {
        autoindent = true,
        breakindent = true,
        clipboard = "unnamedplus",
        cmdheight = 0,
        colorcolumn = "100",
        completeopt = { "menu", "menuone", "noselect" },
        copyindent = true,
        cursorcolumn = false,
        cursorline = true,
        expandtab = true,
        fileencoding = "utf-8",
        fillchars = {
            diff = "╱",
            eob = " ",
            fold = " ",
            foldclose = "",
            foldopen = "",
            horiz = "━",
            horizdown = "┳",
            horizup = "┻",
            msgsep = "‾",
            vert = "┃",
            verthoriz = "╋",
            vertleft = "┫",
            vertright = "┣",
        },
        foldcolumn = "1",
        foldenable = true,
        foldexpr = "nvim_treesitter#foldexpr()",
        foldlevel = 99,
        foldlevelstart = -1,
        foldmethod = "expr",
        hidden = true,
        history = 100,
        ignorecase = true,
        incsearch = true,
        infercase = true,
        laststatus = 3,
        lazyredraw = false,
        linebreak = true,
        matchtime = 1,
        modeline = true,
        modelines = 100,
        mouse = "a",
        mousemodel = "extend",
        number = true,
        preserveindent = true,
        pumheight = 10,
        relativenumber = true,
        report = 9001,
        shiftwidth = 2,
        showmatch = true,
        showmode = false,
        showtabline = 2,
        signcolumn = "yes",
        smartcase = true,
        softtabstop = 0,
        spell = true,
        spelllang = { "en_us" },
        splitbelow = true,
        splitright = true,
        startofline = true,
        swapfile = false,
        synmaxcol = 240,
        tabstop = 2,
        termguicolors = true,
        textwidth = 0,
        timeoutlen = 500,
        title = true,
        undofile = true,
        updatetime = 100,
        virtualedit = "block",
        wrap = false,
        writebackup = false,
    }

    for k, v in pairs(nixvim_options) do
        vim.opt[k] = v
    end
end
-- }}}

require("catppuccin").setup({
    default_integrations = true,
    dim_inactive = { enabled = false, percentage = 0.25 },
    flavour = "macchiato",
    integrations = {
        aerial = true,
        cmp = true,
        dap = { enable_ui = true, enabled = true },
        dap_ui = true,
        diffview = true,
        fidget = true,
        gitsigns = true,
        harpoon = true,
        headlines = true,
        hop = true,
        indent_blankline = { colored_indent_levels = true, enabled = true },
        leap = true,
        lsp_trouble = true,
        markdown = true,
        mason = true,
        mini = { enabled = true },
        native_lsp = {
            enabled = true,
            inlay_hints = { background = true },
            underlines = {
                errors = { "underline" },
                hints = { "underline" },
                information = { "underline" },
                warnings = { "underline" },
            },
            virtual_text = {
                errors = { "italic" },
                hints = { "italic" },
                information = { "italic" },
                warnings = { "italic" },
            },
        },
        navic = { enabled = true },
        neogit = true,
        neotest = true,
        neotree = false,
        noice = true,
        notify = true,
        overseer = true,
        rainbow_delimiters = true,
        sandwich = true,
        semantic_tokens = true,
        symbols_outline = true,
        telescope = { enabled = true, style = "nvchad" },
        treesitter = true,
        ufo = true,
        which_key = true,
    },
    show_end_of_buffer = true,
    term_colors = true,
    transparent_background = true,
})

vim.loader.enable()
-- Highlight groups {{
do
    local highlights = { ExtraWhitespace = { bg = "red" } }

    for k, v in pairs(highlights) do
        vim.api.nvim_set_hl(0, k, v)
    end
end
-- }}

-- Match groups {{
do
    local match = { ExtraWhitespace = "\\s\\+$" }

    for k, v in pairs(match) do
        vim.fn.matchadd(k, v)
    end
end
-- }}

vim.diagnostic.config({ update_in_insert = true, virtual_text = false })

require("smartcolumn").setup({
    colorcolumn = "80",

    disabled_filetypes = {
        "help",
        "text",
        "markdown",
        "neo-tree",
        "checkhealth",
        "lspinfo",
        "noice",
    },

    custom_colorcolumn = {
        go = { "100", "130" },
        java = { "100", "140" },
        nix = { "100", "120" },
        rust = { "80", "100" },
    },

    scope = "file",
})

local function in_comment(pattern)
    return function(buf_id)
        local cs = vim.bo[buf_id].commentstring
        if cs == nil or cs == "" then
            cs = "# %s"
        end

        -- Extract left and right part relative to '%s'
        local left, right = cs:match("^(.*)%%s(.-)$")
        left, right = vim.trim(left), vim.trim(right)
        -- General ideas:
        -- - Line is commented if it has structure
        -- "whitespace - comment left - anything - comment right - whitespace"
        -- - Highlight pattern only if it is to the right of left comment part
        --   (possibly after some whitespace)
        -- Example output for '/* %s */' commentstring: '^%s*/%*%s*()TODO().*%*/%s*'
        return string.format("^%%s*%s%%s*()%s().*%s%%s*$", vim.pesc(left), pattern, vim.pesc(right))
    end
end

vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticError", linehl = "", numhl = "" })
vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
vim.fn.sign_define("DiagnosticSignHint", { text = " 󰌵", texthl = "DiagnosticHint", linehl = "", numhl = "" })
vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticInfo", linehl = "", numhl = "" })

local function preview_location_callback(_, result)
    if result == nil or vim.tbl_isempty(result) then
        vim.notify("No location found to preview")
        return nil
    end
    local buf, _ = vim.lsp.util.preview_location(result[1])
    if buf then
        local cur_buf = vim.api.nvim_get_current_buf()
        vim.bo[buf].filetype = vim.bo[cur_buf].filetype
    end
end

function peek_definition()
    local params = vim.lsp.util.make_position_params()
    return vim.lsp.buf_request(0, "textDocument/definition", params, preview_location_callback)
end

local function peek_type_definition()
    local params = vim.lsp.util.make_position_params()
    return vim.lsp.buf_request(0, "textDocument/typeDefinition", params, preview_location_callback)
end

require("glow").setup({
    border = "single",
    glow_path = "/nix/store/zfsr3syfpi01ghrylwrrfd3n09dj9zqf-glow-2.0.0/bin/glow",
    style = "/nix/store/fvj5sxcsmwvgpyz1x6p56fdbq99kv2yn-source/themes/catppuccin-macchiato.json",
})

local slow_format_filetypes = {}

vim.api.nvim_create_user_command("FormatDisable", function(args)
    if args.bang then
        -- FormatDisable! will disable formatting just for this buffer
        vim.b.disable_autoformat = true
    else
        vim.g.disable_autoformat = true
    end
end, {
    desc = "Disable autoformat-on-save",
    bang = true,
})
vim.api.nvim_create_user_command("FormatEnable", function()
    vim.b.disable_autoformat = false
    vim.g.disable_autoformat = false
end, {
    desc = "Re-enable autoformat-on-save",
})
vim.api.nvim_create_user_command("FormatToggle", function(args)
    if args.bang then
        -- Toggle formatting for current buffer
        vim.b.disable_autoformat = not vim.b.disable_autoformat
    else
        -- Toggle formatting globally
        vim.g.disable_autoformat = not vim.g.disable_autoformat
    end
end, {
    desc = "Toggle autoformat-on-save",
    bang = true,
})

function bool2str(bool)
    return bool and "on" or "off"
end

vim.cmd([[
let $BAT_THEME = 'Catppuccin Macchiato'

colorscheme catppuccin

]])

require("cmp_git").setup({})

require("otter").setup({
    buffers = { set_filetype = true },
    handle_leading_whitespace = true,
    lsp = { diagnostic_update_events = { "BufWritePost", "InsertLeave", "TextChanged" } },
})

require("markview").setup({ hybrid_modes = { "i", "r" }, mode = { "n", "x", "i", "r" } })

require("debugprint").setup({
    commands = { delete_debug_prints = "DeleteDebugPrints", toggle_comment_debug_prints = "ToggleCommentDebugPrints" },
    display_counter = true,
    display_snippet = true,
    keymaps = {
        normal = {
            delete_debug_prints = nil,
            plain_above = "g?P",
            plain_below = "g?p",
            textobj_above = "g?O",
            textobj_below = "g?o",
            toggle_comment_debug_prints = nil,
            variable_above = "g?V",
            variable_above_alwaysprompt = nil,
            variable_below = "g?v",
            variable_below_alwaysprompt = nil,
        },
        visual = { variable_above = "g?V", variable_below = "g?v" },
    },
})

local cmp = require("cmp")
cmp.setup({
    formatting = {
        format = require("lspkind").cmp_format({
            menu = {
                buffer = "",
                calc = "",
                cmdline = "",
                codeium = "󱜙",
                emoji = "󰞅",
                git = "",
                luasnip = "󰩫",
                neorg = "",
                nvim_lsp = "",
                nvim_lua = "",
                path = "",
                spell = "",
                treesitter = "󰔱",
            },
        }),
    },
    mapping = {
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-e>"] = cmp.mapping.close(),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<CR>"] = cmp.mapping.confirm({ select = false, behavior = cmp.ConfirmBehavior.Replace }),
        ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), { "i", "s" }),
        ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), { "i", "s" }),
    },
    preselect = cmp.PreselectMode.None,
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
    sources = {
        {
            name = "nvim_lsp",
            option = {
                get_bufnrs = function()
                    local buf_size_limit = 1024 * 1024 -- 1MB size limit
                    local bufs = vim.api.nvim_list_bufs()
                    local valid_bufs = {}
                    for _, buf in ipairs(bufs) do
                        if
                            vim.api.nvim_buf_is_loaded(buf)
                            and vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf)) < buf_size_limit
                        then
                            table.insert(valid_bufs, buf)
                        end
                    end
                    return valid_bufs
                end,
            },
            priority = 1000,
        },
        {
            name = "nvim_lsp_signature_help",
            option = {
                get_bufnrs = function()
                    local buf_size_limit = 1024 * 1024 -- 1MB size limit
                    local bufs = vim.api.nvim_list_bufs()
                    local valid_bufs = {}
                    for _, buf in ipairs(bufs) do
                        if
                            vim.api.nvim_buf_is_loaded(buf)
                            and vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf)) < buf_size_limit
                        then
                            table.insert(valid_bufs, buf)
                        end
                    end
                    return valid_bufs
                end,
            },
            priority = 1000,
        },
        {
            name = "nvim_lsp_document_symbol",
            option = {
                get_bufnrs = function()
                    local buf_size_limit = 1024 * 1024 -- 1MB size limit
                    local bufs = vim.api.nvim_list_bufs()
                    local valid_bufs = {}
                    for _, buf in ipairs(bufs) do
                        if
                            vim.api.nvim_buf_is_loaded(buf)
                            and vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf)) < buf_size_limit
                        then
                            table.insert(valid_bufs, buf)
                        end
                    end
                    return valid_bufs
                end,
            },
            priority = 1000,
        },
        {
            name = "treesitter",
            option = {
                get_bufnrs = function()
                    local buf_size_limit = 1024 * 1024 -- 1MB size limit
                    local bufs = vim.api.nvim_list_bufs()
                    local valid_bufs = {}
                    for _, buf in ipairs(bufs) do
                        if
                            vim.api.nvim_buf_is_loaded(buf)
                            and vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf)) < buf_size_limit
                        then
                            table.insert(valid_bufs, buf)
                        end
                    end
                    return valid_bufs
                end,
            },
            priority = 850,
        },
        { name = "luasnip", priority = 750 },
        { name = "codeium", priority = 300 },
        {
            name = "buffer",
            option = {
                get_bufnrs = function()
                    local buf_size_limit = 1024 * 1024 -- 1MB size limit
                    local bufs = vim.api.nvim_list_bufs()
                    local valid_bufs = {}
                    for _, buf in ipairs(bufs) do
                        if
                            vim.api.nvim_buf_is_loaded(buf)
                            and vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf)) < buf_size_limit
                        then
                            table.insert(valid_bufs, buf)
                        end
                    end
                    return valid_bufs
                end,
            },
            priority = 500,
        },
        { name = "path", priority = 300 },
        { name = "cmdline", priority = 300 },
        { name = "spell", priority = 300 },
        { name = "fish", priority = 250 },
        { name = "git", priority = 250 },
        { name = "neorg", priority = 250 },
        { name = "npm", priority = 250 },
        { name = "tmux", priority = 250 },
        { name = "zsh", priority = 250 },
        { name = "calc", priority = 150 },
        { name = "emoji", priority = 100 },
    },
    window = { completion = cmp.config.window.bordered(), documentation = cmp.config.window.bordered() },
})

require("yazi").setup({})

do
    local utils = require("yanky.utils")
    local mapping = require("yanky.telescope.mapping")

    require("yanky").setup({})
end

require("which-key").setup({
    replace = {
        desc = {
            { "<space>", "SPACE" },
            { "<leader>", "SPACE" },
            { "<[cC][rR]>", "RETURN" },
            { "<[tT][aA][bB]>", "TAB" },
            { "<[bB][sS]>", "BACKSPACE" },
        },
    },
    spec = {
        { "<leader>c", group = "Codesnap", icon = "󰄄 ", mode = "v" },
        { "<leader>lc", group = "Comment-box", icon = " " },
        { "<leader>d", desc = "Debug", mode = "n" },
        { "<leader>gW", group = "Worktree", icon = "󰙅 " },
        { "<leader>gh", group = "Hunks", icon = " " },
        { "<leader>ug", group = "Git" },
        { "<leader>p", group = "Preview", icon = " ", mode = "n" },
        { "<leader>h", group = "Harpoon", icon = "󱡀 " },
        { "<leader>ha", desc = "Add" },
        { "<leader>he", desc = "QuickMenu" },
        { "<leader>hj", desc = "1" },
        { "<leader>hk", desc = "2" },
        { "<leader>hl", desc = "3" },
        { "<leader>hm", desc = "4" },
        { "<leader>l", group = "LSP", icon = " " },
        { "<leader>la", desc = "Code Action" },
        { "<leader>ld", desc = "Definition" },
        { "<leader>lD", desc = "References" },
        { "<leader>lf", desc = "Format" },
        { "<leader>l[", desc = "Prev" },
        { "<leader>l]", desc = "Next" },
        { "<leader>lt", desc = "Type Definition" },
        { "<leader>li", desc = "Implementation" },
        { "<leader>lh", desc = "Lsp Hover" },
        { "<leader>lH", desc = "Diagnostic Hover" },
        { "<leader>lr", desc = "Rename" },
        { "<leader>n", group = "Neotest", icon = "󰙨" },
        { "<leader>r", group = "Refactor", icon = " ", mode = "x" },
        { "<leader>x", group = " Trouble", mode = "n" },
        { "<leader>b", group = "Buffers" },
        { "<leader>bs", group = "󰒺 Sort", icon = "" },
        { "<leader>g", group = "Git" },
        { "<leader>f", group = "Find" },
        { "<leader>r", group = "Refactor", icon = " " },
        { "<leader>t", group = "Terminal" },
        { "<leader>u", group = "UI/UX" },
    },
    win = { border = "single" },
})

require("trouble").setup({
    modes = {
        preview_float = {
            mode = "diagnostics",
            preview = {
                border = "rounded",
                position = { 0, -2 },
                relative = "editor",
                size = { height = 0.3, width = 0.3 },
                title = "Preview",
                title_pos = "center",
                type = "float",
                zindex = 200,
            },
        },
        preview_split = {
            mode = "diagnostics",
            preview = { position = "right", relative = "win", size = 0.5, type = "split" },
        },
    },
})

vim.opt.runtimepath:prepend(vim.fs.joinpath(vim.fn.stdpath("data"), "site"))
require("nvim-treesitter.configs").setup({
    highlight = {
        additional_vim_regex_highlighting = true,
        disable = function(lang, bufnr)
            return vim.api.nvim_buf_line_count(bufnr) > 10000
        end,
        enable = true,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gnn",
            node_decremental = "grm",
            node_incremental = "grn",
            scope_incremental = "grc",
        },
    },
    indent = { enable = true },
    parser_install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site"),
    refactor = {
        highlight_current_scope = { enable = false },
        highlight_definitions = { clear_on_cursor_move = true, enable = true },
        navigation = {
            enable = true,
            keymaps = {
                goto_definition = "gnd",
                goto_next_usage = "<a-*>",
                goto_previous_usage = "<a-#>",
                list_definitions = "gnD",
                list_definitions_toc = "gO",
            },
        },
        smart_rename = { enable = true, keymaps = { smart_rename = "grr" } },
    },
})

require("toggleterm").setup({ direction = "float" })

require("todo-comments").setup({})

require("telescope").setup({
    defaults = {
        file_ignore_patterns = { "^.git/", "^.mypy_cache/", "^__pycache__/", "^output/", "^data/", "%.ipynb" },
        file_sorter = require("mini.fuzzy").get_telescope_sorter,
        generic_sorter = require("mini.fuzzy").get_telescope_sorter,
        set_env = { COLORTERM = "truecolor" },
    },
    extensions = {
        file_browser = { hidden = true },
        frecency = { auto_validate = false },
        ["ui-select"] = { require("telescope.themes").get_dropdown({}) },
        undo = { layout_config = { preview_height = 0.8 }, layout_strategy = "vertical", side_by_side = true },
    },
    pickers = { colorscheme = { enable_preview = true } },
})

local __telescopeExtensions = { "undo", "ui-select", "frecency", "file_browser", "projects", "refactoring" }
for i, extension in ipairs(__telescopeExtensions) do
    require("telescope").load_extension(extension)
end

require("statuscol").setup({
    relculright = true,
    segments = {
        { click = "v:lua.ScFa", hl = "FoldColumn", text = { require("statuscol.builtin").foldfunc } },
        {
            click = "v:lua.ScSa",
            sign = { auto = true, maxwidth = 2, name = { ".*" }, namespace = { ".*" }, text = { ".*" } },
        },
        { click = "v:lua.ScLa", text = { " ", require("statuscol.builtin").lnumfunc, " " } },
        { click = "v:lua.ScSa", sign = { auto = true, colwidth = 1, maxwidth = 2, name = { ".*" }, wrap = true } },
    },
})

require("spectre").setup({})

require("rest-nvim").setup({})

require("refactoring").setup({})

require("project_nvim").setup({})

require("nvim-lightbulb").setup({
    autocmd = { enabled = true, updatetime = 200 },
    line = { enabled = true },
    number = { enabled = true },
    sign = { enabled = true, text = " 󰌶" },
    status_text = { enabled = true, text = " 󰌶 " },
})

require("neotest").setup({
    adapters = {
        require("rustaceanvim.neotest"),
        require("neotest-bash"),
        require("neotest-deno"),
        require("neotest-dotnet")({ dap = { args = { justMyCode = false } } }),
        require("neotest-go"),
        require("neotest-java"),
        require("neotest-jest"),
        require("neotest-playwright"),
        require("neotest-plenary"),
        require("neotest-python"),
        require("neotest-zig"),
    },
})

require("nvim-navic").setup({ lsp = { auto_attach = true, preference = { "clangd", "tsserver" } } })

require("mini.ai").setup({})

require("mini.align").setup({})

require("mini.basics").setup({})

require("mini.bracketed").setup({})

require("mini.bufremove").setup({})

require("mini.comment").setup({
    mappings = {
        comment = "<leader>/",
        comment_line = "<leader>/",
        comment_visual = "<leader>/",
        textobject = "<leader>/",
    },
})

require("mini.diff").setup({ view = { style = "sign" } })

require("mini.fuzzy").setup({})

require("mini.git").setup({})

require("mini.hipatterns").setup({
    highlighters = { hex_color = require("mini.hipatterns").gen_highlighter.hex_color() },
})

require("mini.icons").setup({})

require("mini.indentscope").setup({})

require("mini.map").setup({
    integrations = {
        require("mini.map").gen_integration.builtin_search(),
        require("mini.map").gen_integration.diagnostic(),
        require("mini.map").gen_integration.gitsigns(),
    },
    window = { winblend = 0 },
})

require("mini.pairs").setup({})

require("mini.starter").setup({
    content_hooks = {
        require("mini.starter").gen_hook.adding_bullet(),
        require("mini.starter").gen_hook.indexing("all", { "Builtin actions" }),
        require("mini.starter").gen_hook.aligning("center", "center"),
    },
    evaluate_single = true,
    header = "██╗  ██╗██╗  ██╗ █████╗ ███╗   ██╗███████╗██╗     ██╗███╗   ██╗██╗██╗  ██╗\n██║ ██╔╝██║  ██║██╔══██╗████╗  ██║██╔════╝██║     ██║████╗  ██║██║╚██╗██╔╝\n█████╔╝ ███████║███████║██╔██╗ ██║█████╗  ██║     ██║██╔██╗ ██║██║ ╚███╔╝\n██╔═██╗ ██╔══██║██╔══██║██║╚██╗██║██╔══╝  ██║     ██║██║╚██╗██║██║ ██╔██╗\n██║  ██╗██║  ██║██║  ██║██║ ╚████║███████╗███████╗██║██║ ╚████║██║██╔╝ ██╗\n╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝\n",
    items = {
        require("mini.starter").sections.builtin_actions(),
        require("mini.starter").sections.recent_files(10, true),
        require("mini.starter").sections.recent_files(10, false),
        require("mini.starter").sections.sessions(5, true),
    },
})

require("mini.surround").setup({
    mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr",
        update_n_lines = "gsn",
    },
})
MiniIcons.mock_nvim_web_devicons()

require("lualine").setup({
    options = {
        disabled_filetypes = { "startify", "neo-tree", winbar = { "aerial", "dap-repl", "neotest-summary" } },
        globalstatus = true,
        theme = "catppuccin",
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = { "filename", "diff" },
        lualine_x = {
            "diagnostics",
            {
                function()
                    local msg = ""
                    local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
                    local clients = vim.lsp.get_active_clients()
                    if next(clients) == nil then
                        return msg
                    end
                    for _, client in ipairs(clients) do
                        local filetypes = client.config.filetypes
                        if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                            return client.name
                        end
                    end
                    return msg
                end,
                color = { fg = "#ffffff" },
                icon = "",
            },
            "encoding",
            "fileformat",
            "filetype",
        },
        lualine_y = {
            {
                "aerial",
                colored = true,
                cond = function()
                    local buf_size_limit = 1024 * 1024 -- 1MB size limit
                    if vim.api.nvim_buf_get_offset(0, vim.api.nvim_buf_line_count(0)) > buf_size_limit then
                        return false
                    end

                    return true
                end,
                dense = false,
                dense_sep = ".",
                depth = nil,
                sep = " ) ",
            },
        },
        lualine_z = {
            {
                "location",
                cond = function()
                    local buf_size_limit = 1024 * 1024 -- 1MB size limit
                    if vim.api.nvim_buf_get_offset(0, vim.api.nvim_buf_line_count(0)) > buf_size_limit then
                        return false
                    end

                    return true
                end,
            },
        },
    },
    winbar = {
        lualine_c = {
            {
                "navic",
                cond = function()
                    local buf_size_limit = 1024 * 1024 -- 1MB size limit
                    if vim.api.nvim_buf_get_offset(0, vim.api.nvim_buf_line_count(0)) > buf_size_limit then
                        return false
                    end

                    return true
                end,
            },
        },
        lualine_x = { { "filename", newfile_status = true, path = 3, shorting_target = 150 } },
    },
})

require("lsp_lines").setup()

require("ibl").setup({ scope = { enabled = false } })

require("hop").setup({})

require("gitsigns").setup({
    current_line_blame = true,
    current_line_blame_opts = {
        delay = 500,
        ignore_blank_lines = true,
        ignore_whitespace = true,
        virt_text = true,
        virt_text_pos = "eol",
    },
    signcolumn = false,
})

require("git-conflict").setup({
    default_mappings = { both = "cb", next = "]x", none = "c0", ours = "co", prev = "[x", theirs = "ct" },
})

require("conform").setup({
    format_after_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
        end

        if not slow_format_filetypes[vim.bo[bufnr].filetype] then
            return
        end

        return { lsp_fallback = true }
    end,
    format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
        end

        if slow_format_filetypes[vim.bo[bufnr].filetype] then
            return
        end

        local function on_format(err)
            if err and err:match("timeout$") then
                slow_format_filetypes[vim.bo[bufnr].filetype] = true
            end
        end

        return { timeout_ms = 200, lsp_fallback = true }, on_format
    end,
    formatters = {
        bicep = { command = "/nix/store/0x4ckq8mf9d8y3nip1cpgmi3rz2krfqc-bicep-0.29.47/bin/bicep" },
        black = { command = "/nix/store/ydsjzs7kb9jf7gskh6j6imbv7dib1cq9-python3.12-black-24.4.2/bin/black" },
        ["cmake-format"] = {
            command = "/nix/store/pv3g8r39ms5vcznrawm69j7rwarwa8n5-cmake-format-0.6.13/bin/cmake-format",
        },
        csharpier = { command = "/nix/store/rwv3z3njplyszgc4y1xz86sblr8qz261-csharpier-0.29.1/bin/dotnet-csharpier" },
        deno_fmt = { command = "/nix/store/siqmrs4cd2xf3ig6q95i4pq8ff8qm9i1-deno-1.46.2/bin/deno" },
        fantomas = { command = "/nix/store/yiakkl6mpz6xnf48khn2cg3nnh0m5wyc-fantomas-6.3.11/bin/fantomas" },
        isort = { command = "/nix/store/4vywaqm2fmik3iq3ggrflkqy2cymc3q1-python3.12-isort-5.13.2/bin/isort" },
        jq = { command = "/nix/store/kc1c2x2a14zsjwxlscajmc59nsz0wd1s-jq-1.7.1-bin/bin/jq" },
        nixfmt = { command = "/nix/store/bxxinic7wzzrvvzjp3jz0sq11c4nja7g-nixfmt-unstable-2024-08-16/bin/nixfmt" },
        prettierd = { command = "/nix/store/dc4ch3lvwgm7i394a03f442nqimmgi17-fsouza-prettierd-0.25.3/bin/prettierd" },
        ruff = { command = "/nix/store/s9sn9llf7xk4hjac2d4phj5zha9gszyh-ruff-0.6.3/bin/ruff" },
        rustfmt = { command = "/nix/store/a9l00r7ghygfwqwd42p24mjmsl22yilx-rustfmt-1.80.1/bin/rustfmt" },
        shellcheck = { command = "/nix/store/drp1l1226v4xzb1vplhl0ik9fqrf99qs-shellcheck-0.10.0-bin/bin/shellcheck" },
        shellharden = { command = "/nix/store/4h2gmqaj0srqajq2advvmib080kddvx3-shellharden-4.3.1/bin/shellharden" },
        shfmt = { command = "/nix/store/yqraq75v6s0sf6lj4zr9wly5v544js9c-shfmt-3.9.0/bin/shfmt" },
        sqlfluff = { command = "/nix/store/9mbxhy9ss45ixmlkvf0an5fpz9w7q6dp-sqlfluff-3.1.1/bin/sqlfluff" },
        squeeze_blanks = { command = "/nix/store/vb8mdklw65p9wikp97ybmnyay0xzipx3-coreutils-9.5/bin/cat" },
        stylelint = { command = "/nix/store/38wknxd1kybbcd6hbfcz8yqb028pwhm9-stylelint-16.8.1/bin/stylelint" },
        stylua = { command = "/nix/store/bvsz1m28gp4xmgjbjlb3a49nq0sj27lv-stylua-0.20.0/bin/stylua" },
        swift_format = { command = "/nix/store/qzmsm1ra7kzyppm8pzdnqw7n4az63d8q-swift-format-5.8/bin/swift-format" },
        taplo = { command = "/nix/store/nbjs7dsvmlq1fflrx9923j55ywnibmkh-taplo-0.9.3/bin/taplo" },
        terraform_fmt = { command = "/nix/store/ldhzakyiqgp1rfpsp27lzyns75c90963-terraform-1.9.5/bin/terraform" },
        xmlformat = { command = "/nix/store/xh1gc434fs9ds9r87ppkwiikvxknl7vg-xmlformat-1.04/bin/xmlformat" },
        yamlfmt = { command = "/nix/store/797j208xyp75spcjn444zws09jp40n3k-yamlfmt-0.13.0/bin/yamlfmt" },
        zigfmt = { command = "/nix/store/7lmwmb7q5r97gkb2ydj4cxqpbyswbl5p-zig-0.13.0/bin/zig" },
    },
    formatters_by_ft = {
        _ = { "squeeze_blanks", "trim_whitespace", "trim_newlines" },
        bash = { "shellcheck", "shellharden", "shfmt" },
        bicep = { "bicep" },
        c = { "clang_format" },
        cmake = { "cmake-format" },
        cpp = { "clang_format" },
        cs = { "csharpier" },
        css = { "stylelint" },
        fish = { "fish_indent" },
        fsharp = { "fantomas" },
        javascript = { "prettierd", "prettier", stop_after_first = true, timeout_ms = 2000 },
        json = { "jq" },
        lua = { "stylua" },
        markdown = { "deno_fmt" },
        nix = { "nixfmt" },
        python = { "isort", "ruff" },
        rust = { "rustfmt" },
        sh = { "shellcheck", "shellharden", "shfmt" },
        sql = { "sqlfluff" },
        swift = { "swift_format" },
        terraform = { "terraform_fmt" },
        toml = { "taplo" },
        typescript = { "prettierd", "prettier", stop_after_first = true, timeout_ms = 2000 },
        xml = { "xmlformat", "xmllint" },
        yaml = { "yamlfmt" },
        zig = { "zigfmt" },
    },
})

require("comment-box").setup({})

require("codesnap").setup({
    breadcrumbs_separator = "/",
    code_font_family = "MonaspiceNe Nerd Font",
    has_breadcrumbs = true,
    has_line_number = false,
    mac_window_bar = true,
    save_path = "$XDG_PICTURES_DIR/screenshots",
    title = "CodeSnap.nvim",
    watermark = "",
})

require("codeium").setup({
    enable_chat = true,
    tools = {
        curl = "/nix/store/814vpcdn87bwwfrbyz49n6ib335sp7ws-curl-8.9.1-bin/bin/curl",
        gzip = "/nix/store/jgl506qlgvv5jciscs0iji2fqn1xi8gc-gzip-1.13/bin/gzip",
        uname = "/nix/store/vb8mdklw65p9wikp97ybmnyay0xzipx3-coreutils-9.5/bin/uname",
        uuidgen = "/nix/store/6l1jzqgjqqa0prgm1xh2iy7z7sg80g39-util-linux-2.39.4-bin/bin/uuidgen",
    },
})

ccc = require("ccc")
ccc.setup({
    alpha_show = "hide",
    convert = {
        { require("ccc").picker.hex, require("ccc").output.css_hsl },
        { require("ccc").picker.css_rgb, require("ccc").output.css_hsl },
        { require("ccc").picker.css_hsl, require("ccc").output.hex },
    },
    highlighter = { auto_enable = true, filetypes = { "colorPickerFts" }, lsp = true, max_byte = 2097152 },
    inputs = { require("ccc").input.hsl },
    mappings = {
        H = require("ccc").mapping.decrease10,
        L = require("ccc").mapping.increase10,
        q = require("ccc").mapping.quit,
    },
    outputs = { require("ccc").output.css_hsl, require("ccc").output.css_rgb, require("ccc").output.hex },
    pickers = {
        require("ccc").picker.hex,
        require("ccc").picker.css_rgb,
        require("ccc").picker.css_hsl,
        require("ccc").picker.ansi_escape({
            meaning1 = "bright",
        }),
    },
    recognize = { output = true },
})

require("bufferline").setup({
    highlights = {
        buffer_selected = { bg = "#363a4f" },
        close_button_selected = { bg = "#363a4f" },
        diagnostic_selected = { bg = "#363a4f" },
        duplicate_selected = { bg = "#363a4f" },
        error_diagnostic_selected = { bg = "#363a4f" },
        error_selected = { bg = "#363a4f" },
        fill = { bg = "#1e2030" },
        hint_diagnostic_selected = { bg = "#363a4f" },
        hint_selected = { bg = "#363a4f" },
        info_diagnostic_selected = { bg = "#363a4f" },
        info_selected = { bg = "#363a4f" },
        modified_selected = { bg = "#363a4f" },
        numbers_selected = { bg = "#363a4f" },
        separator = { fg = "#1e2030" },
        separator_selected = { bg = "#363a4f", fg = "#1e2030" },
        separator_visible = { fg = "#1e2030" },
        tab_selected = { bg = "#363a4f" },
        warning_diagnostic_selected = { bg = "#363a4f" },
        warning_selected = { bg = "#363a4f" },
    },
    options = {
        always_show_bufferline = true,
        buffer_close_icon = "󰅖",
        close_command = function(bufnum)
            require("mini.bufremove").delete(bufnum)
        end,
        close_icon = "",
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local s = ""
            for e, n in pairs(diagnostics_dict) do
                local sym = e == "error" and " " or (e == "warning" and " " or "")
                if sym ~= "" then
                    s = s .. " " .. n .. sym
                end
            end
            return s
        end,
        enforce_regular_tabs = false,
        groups = {
            items = {
                {
                    highlight = { fg = "#a6da95", sp = "#494d64", underline = true },
                    matcher = function(buf)
                        return buf.name:match("%test") or buf.name:match("%.spec")
                    end,
                    name = "Tests",
                    priority = 2,
                },
                {
                    auto_close = false,
                    highlight = { fg = "#ffffff", sp = "#494d64", undercurl = true },
                    matcher = function(buf)
                        return buf.name:match("%.md") or buf.name:match("%.txt")
                    end,
                    name = "Docs",
                },
            },
            options = { toggle_hidden_on_enter = true },
        },
        indicator = { icon = "▎", style = "icon" },
        left_trunc_marker = "",
        max_name_length = 18,
        max_prefix_length = 15,
        mode = "buffers",
        modified_icon = "●",
        numbers = function(opts)
            return string.format("%s·%s", opts.raise(opts.id), opts.lower(opts.ordinal))
        end,
        offsets = { { filetype = "neo-tree", highlight = "Directory", text = "File Explorer", text_align = "center" } },
        persist_buffer_sort = true,
        right_mouse_command = "vertical sbuffer %d",
        right_trunc_marker = "",
        separator_style = "slant",
        show_buffer_close_icons = true,
        show_buffer_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        sort_by = "extension",
        tab_size = 18,
    },
})

-- LSP {{{
do
    local __clangdCaps = vim.lsp.protocol.make_client_capabilities()
    __clangdCaps.offsetEncoding = { "utf-16" }

    local __lspServers = {
        { extraOptions = { filetypes = { "yaml" } }, name = "yamlls" },
        {
            extraOptions = { filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" } },
            name = "tsserver",
        },
        { extraOptions = { filetypes = { "toml" } }, name = "taplo" },
        { extraOptions = { filetypes = { "sql" } }, name = "sqls" },
        { extraOptions = { filetypes = { "python" } }, name = "ruff" },
        { extraOptions = { filetypes = { "python" } }, name = "pyright" },
        {
            extraOptions = {
                filetypes = { "nix" },
                settings = {
                    ["nil"] = {
                        formatting = {
                            command = {
                                "/nix/store/bxxinic7wzzrvvzjp3jz0sq11c4nja7g-nixfmt-unstable-2024-08-16/bin/nixfmt",
                            },
                        },
                        nix = { flake = { autoArchive = true } },
                    },
                },
            },
            name = "nil_ls",
        },
        { extraOptions = { filetypes = { "markdown" } }, name = "marksman" },
        { extraOptions = { filetypes = { "lua" } }, name = "lua_ls" },
        {
            extraOptions = {
                cmd = {
                    "/nix/store/1qwhaf3gnk3k688wy5a05apgl99ngp7l-vscode-langservers-extracted-4.10.0/bin/vscode-json-language-server",
                    "--stdio",
                },
                filetypes = { "json", "jsonc" },
            },
            name = "jsonls",
        },
        {
            extraOptions = {
                cmd = { "/nix/store/81j7fggnmmnnkh10grl4q5xvd4z9arg9-jdt-language-server-1.38.0/bin/jdtls" },
                filetypes = { "java" },
            },
            name = "jdtls",
        },
        {
            extraOptions = {
                cmd = {
                    "/nix/store/1qwhaf3gnk3k688wy5a05apgl99ngp7l-vscode-langservers-extracted-4.10.0/bin/vscode-html-language-server",
                    "--stdio",
                },
                filetypes = { "html" },
            },
            name = "html",
        },
        { extraOptions = { filetypes = { "helm" } }, name = "helm_ls" },
        { extraOptions = { filetypes = { "gd", "gdscript", "gdscript3" } }, name = "gdscript" },
        { extraOptions = { filetypes = { "fsharp" } }, name = "fsautocomplete" },
        {
            extraOptions = {
                cmd = {
                    "/nix/store/1qwhaf3gnk3k688wy5a05apgl99ngp7l-vscode-langservers-extracted-4.10.0/bin/vscode-eslint-language-server",
                    "--stdio",
                },
                filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
            },
            name = "eslint",
        },
        {
            extraOptions = {
                cmd = {
                    "/nix/store/bndwgqz05dm1shn8p8l2hdvdvanzzkax-dockerfile-language-server-nodejs-0.11.0/bin/docker-langserver",
                    "--stdio",
                },
                filetypes = { "dockerfile" },
            },
            name = "dockerls",
        },
        {
            extraOptions = {
                cmd = {
                    "/nix/store/1qwhaf3gnk3k688wy5a05apgl99ngp7l-vscode-langservers-extracted-4.10.0/bin/vscode-css-language-server",
                    "--stdio",
                },
                filetypes = { "css", "less", "scss" },
            },
            name = "cssls",
        },
        { extraOptions = { filetypes = { "cs" } }, name = "csharp_ls" },
        { extraOptions = { filetypes = { "cmake" } }, name = "cmake" },
        {
            extraOptions = { capabilities = __clangdCaps, filetypes = { "c", "cpp", "objc", "objcpp" } },
            name = "clangd",
        },
        {
            extraOptions = {
                filetypes = { "c", "cpp", "objc", "objcpp" },
                init_options = { compilationDatabaseDirectory = "build" },
            },
            name = "ccls",
        },
        { extraOptions = { filetypes = { "sh", "bash" } }, name = "bashls" },
    }
    -- Adding lspOnAttach function to nixvim module lua table so other plugins can hook into it.
    _M.lspOnAttach = function(client, bufnr) end
    local __lspCapabilities = function()
        capabilities = vim.lsp.protocol.make_client_capabilities()

        capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

        return capabilities
    end

    local __setup = {
        on_attach = _M.lspOnAttach,
        capabilities = __lspCapabilities(),
    }

    for i, server in ipairs(__lspServers) do
        if type(server) == "string" then
            require("lspconfig")[server].setup(__setup)
        else
            local options = server.extraOptions

            if options == nil then
                options = __setup
            else
                options = vim.tbl_extend("keep", options, __setup)
            end

            require("lspconfig")[server.name].setup(options)
        end
    end

    require("clangd_extensions").setup({
        ast = {
            kind_icons = {
                Compound = "",
                PackExpansion = "",
                Recovery = "",
                TemplateParamObject = "",
                TemplateTemplateParm = "",
                TemplateTypeParm = "",
                TranslationUnit = "",
            },
            role_icons = {
                declaration = "",
                expression = "",
                specifier = "",
                statement = "",
                ["template argument"] = "",
                type = "",
            },
        },
    })
end
-- }}}

vim.notify = require("notify")
require("notify").setup({})

require("noice").setup({
    cmdline = {
        format = {
            cmdline = { icon = "", lang = "vim", opts = { border = { text = { top = "Cmd" } } }, pattern = "^:" },
            filter = {
                icon = "",
                lang = "bash",
                opts = { border = { text = { top = "Bash" } } },
                pattern = "^:%s*!",
            },
            help = { icon = "󰋖", pattern = "^:%s*he?l?p?%s+" },
            lua = { icon = "", lang = "lua", pattern = "^:%s*lua%s+" },
            search_down = { icon = " ", kind = "search", lang = "regex", pattern = "^/" },
            search_up = { icon = " ", kind = "search", lang = "regex", pattern = "^%?" },
        },
    },
    lsp = {
        override = {
            ["cmp.entry.get_documentation"] = true,
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
        },
        progress = { enabled = true },
        signature = { enabled = true },
    },
    messages = { view = "mini", view_error = "mini", view_warn = "mini" },
    popupmenu = { backend = "nui" },
    presets = {
        bottom_search = false,
        command_palette = true,
        inc_rename = true,
        long_message_to_split = true,
        lsp_doc_border = true,
    },
    routes = {
        { filter = { event = "msg_show", kind = "search_count" }, opts = { skip = true } },
        {
            filter = {
                cond = function(message)
                    local client = vim.tbl_get(message.opts, "progress", "client")
                    local servers = { "jdtls" }

                    for index, value in ipairs(servers) do
                        if value == client then
                            return true
                        end
                    end
                end,
                event = "lsp",
                kind = "progress",
            },
            opts = { skip = true },
        },
    },
    views = {
        cmdline_popup = { border = { style = "single" } },
        confirm = { border = { style = "single", text = { top = "" } } },
    },
})

local __ignored_variables = {}
for ignoredVariable, shouldIgnore in ipairs(__ignored_variables) do
    require("nix-develop").ignored_variables[ignoredVariable] = shouldIgnore
end

local __separated_variables = {}
for variable, separator in ipairs(__separated_variables) do
    require("nix-develop").separated_variables[variable] = separator
end

require("neo-tree").setup({
    close_if_last_window = true,
    document_symbols = { custom_kinds = {} },
    filesystem = {
        filtered_items = {
            hide_dotfiles = false,
            hide_hidden = false,
            never_show_by_pattern = { ".direnv", ".git" },
            visible = true,
        },
        follow_current_file = { enabled = true, leaveDirsOpen = true },
        use_libuv_file_watcher = vim.fn.has("win32") ~= 1,
    },
    window = { auto_expand_width = false, width = 40 },
})

require("luasnip").config.setup({})

require("luasnip.loaders.from_vscode").lazy_load({})

require("leap").add_default_mappings()
require("leap").opts = vim.tbl_deep_extend("keep", {}, require("leap").opts)

require("illuminate").configure({
    filetypes_denylist = { "dirvish", "fugitive", "neo-tree", "TelescopePrompt" },
    large_file_cutoff = 3000,
})

require("harpoon").setup({})

require("git-worktree").setup({ enabled = true })
require("telescope").load_extension("git_worktree")

require("diffview").setup({ use_icons = true })

require("dap").adapters = {
    bashdb = {
        command = "/nix/store/56xiy5ava7li2ndrmnwxr425abhyj4lg-bashdb-5.0-1.1.2/bin/bashdb",
        type = "executable",
    },
    codelldb = {
        executable = {
            args = { "--port", "13000" },
            command = "/nix/store/7dyyy5kjlxdps85mrvqa0dvksfadlxyq-vscode-extension-vadimcn-vscode-lldb-1.10.0/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb",
        },
        port = 13000,
        type = "server",
    },
    coreclr = {
        args = { "--interpreter=vscode" },
        command = "/nix/store/290z084qg1rglk9d8b8qx4nvkxbhgcb2-netcoredbg-3.1.0-1031/bin/netcoredbg",
        type = "executable",
    },
    cppdbg = { args = { "-i", "dap" }, command = "gdb", type = "executable" },
    gdb = { args = { "-i", "dap" }, command = "gdb", type = "executable" },
    lldb = { command = "/nix/store/6r5jvr6knhl8i6van4l09c50zapajr4b-lldb-18.1.8/bin/lldb-vscode", type = "executable" },
    netcoredbg = {
        args = { "--interpreter=vscode" },
        command = "/nix/store/290z084qg1rglk9d8b8qx4nvkxbhgcb2-netcoredbg-3.1.0-1031/bin/netcoredbg",
        type = "executable",
    },
}
require("dap").configurations = {
    c = {
        {
            cwd = "${workspaceFolder}",
            name = "Launch (LLDB)",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            request = "launch",
            stopOnEntry = false,
            type = "lldb",
        },
        {
            cwd = "${workspaceFolder}",
            name = "Launch (GDB)",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            request = "launch",
            stopOnEntry = false,
            type = "gdb",
        },
    },
    cpp = {
        {
            cwd = "${workspaceFolder}",
            name = "Launch (LLDB)",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            request = "launch",
            stopOnEntry = false,
            type = "lldb",
        },
        {
            cwd = "${workspaceFolder}",
            name = "Launch (GDB)",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            request = "launch",
            stopOnEntry = false,
            type = "gdb",
        },
        {
            cwd = "${workspaceFolder}",
            name = "Launch (CodeLLDB)",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            request = "launch",
            stopOnEntry = false,
            type = "codelldb",
        },
    },
    cs = {
        {
            cwd = "${workspaceFolder}",
            name = "launch - netcoredbg",
            progra = function()
                if vim.fn.confirm("Should I recompile first?", "&yes\n&no", 2) == 1 then
                    vim.g.dotnet_build_project()
                end

                return vim.g.dotnet_get_dll_path()
            end,
            request = "launch",
            type = "coreclr",
        },
        {
            cwd = "${workspaceFolder}",
            name = "launch - netcoredbg",
            progra = function()
                if vim.fn.confirm("Should I recompile first?", "&yes\n&no", 2) == 1 then
                    vim.g.dotnet_build_project()
                end

                return vim.g.dotnet_get_dll_path()
            end,
            request = "launch",
            type = "coreclr",
        },
    },
    fsharp = {
        {
            cwd = "${workspaceFolder}",
            name = "launch - netcoredbg",
            progra = function()
                if vim.fn.confirm("Should I recompile first?", "&yes\n&no", 2) == 1 then
                    vim.g.dotnet_build_project()
                end

                return vim.g.dotnet_get_dll_path()
            end,
            request = "launch",
            type = "coreclr",
        },
        {
            cwd = "${workspaceFolder}",
            name = "launch - netcoredbg",
            progra = function()
                if vim.fn.confirm("Should I recompile first?", "&yes\n&no", 2) == 1 then
                    vim.g.dotnet_build_project()
                end

                return vim.g.dotnet_get_dll_path()
            end,
            request = "launch",
            type = "coreclr",
        },
    },
    rust = {
        {
            cwd = "${workspaceFolder}",
            name = "Launch (LLDB)",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            request = "launch",
            stopOnEntry = false,
            type = "lldb",
        },
        {
            cwd = "${workspaceFolder}",
            name = "Launch (GDB)",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            request = "launch",
            stopOnEntry = false,
            type = "gdb",
        },
        {
            cwd = "${workspaceFolder}",
            name = "Launch (CodeLLDB)",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            request = "launch",
            stopOnEntry = false,
            type = "codelldb",
        },
    },
    sh = {
        {
            cwd = "${workspaceFolder}",
            file = "${file}",
            name = "Launch (BashDB)",
            pathBash = "/nix/store/vpvy79k1qq02p1vyqjk6nb89gwhxqvyb-bash-5.2p32/bin/bash",
            pathBashdb = "/nix/store/56xiy5ava7li2ndrmnwxr425abhyj4lg-bashdb-5.0-1.1.2/bin/bashdb",
            pathBashdbLib = "/nix/store/56xiy5ava7li2ndrmnwxr425abhyj4lg-bashdb-5.0-1.1.2/share/basdhb/lib/",
            pathCat = "cat",
            pathMkfifo = "mkfifo",
            pathPkill = "pkill",
            program = "${file}",
            request = "launch",
            showDebugOutput = true,
            terminalKind = "integrated",
            trace = true,
            type = "bashdb",
        },
    },
}
local __dap_signs = {
    DapBreakpoint = { text = "", texthl = "DapBreakpoint" },
    DapBreakpointCondition = { text = "", texthl = "dapBreakpointCondition" },
    DapBreakpointRejected = { text = "", texthl = "DapBreakpointRejected" },
    DapLogPoint = { text = "", texthl = "DapLogPoint" },
    DapStopped = { text = "", texthl = "DapStopped" },
}
for sign_name, sign in pairs(__dap_signs) do
    vim.fn.sign_define(sign_name, sign)
end
require("nvim-dap-virtual-text").setup({})

require("dapui").setup({})

-- Set up keybinds {{{
do
    local __nixvim_binds = {
        { action = "<cmd>TodoTelescope keywords=TODO,FIX,FIX<cr>", key = "<leader>ft", mode = "n" },
        { action = "<cmd>TodoTrouble<cr>", key = "<leader>xq", mode = "n" },
        { action = "<cmd>Telescope marks<cr>", key = "<leader>f'", mode = "n", options = { desc = "View marks" } },
        {
            action = "<cmd>Telescope current_buffer_fuzzy_find<cr>",
            key = "<leader>f/",
            mode = "n",
            options = { desc = "Fuzzy find in current buffer" },
        },
        {
            action = "<cmd>Telescope resume<cr>",
            key = "<leader>f<CR>",
            mode = "n",
            options = { desc = "Resume action" },
        },
        { action = "<cmd>Telescope commands<cr>", key = "<leader>fC", mode = "n", options = { desc = "View commands" } },
        {
            action = "<cmd>Telescope autocommands<cr>",
            key = "<leader>fa",
            mode = "n",
            options = { desc = "View autocommands" },
        },
        { action = "<cmd>Telescope buffers<cr>", key = "<leader>fb", mode = "n", options = { desc = "View buffers" } },
        {
            action = "<cmd>Telescope grep_string<cr>",
            key = "<leader>fc",
            mode = "n",
            options = { desc = "Grep string" },
        },
        {
            action = "<cmd>Telescope diagnostics<cr>",
            key = "<leader>fd",
            mode = "n",
            options = { desc = "View diagnostics" },
        },
        { action = "<cmd>Telescope find_files<cr>", key = "<leader>ff", mode = "n", options = { desc = "Find files" } },
        {
            action = "<cmd>Telescope help_tags<cr>",
            key = "<leader>fh",
            mode = "n",
            options = { desc = "View help tags" },
        },
        { action = "<cmd>Telescope keymaps<cr>", key = "<leader>fk", mode = "n", options = { desc = "View keymaps" } },
        {
            action = "<cmd>Telescope man_pages<cr>",
            key = "<leader>fm",
            mode = "n",
            options = { desc = "View man pages" },
        },
        {
            action = "<cmd>Telescope oldfiles<cr>",
            key = "<leader>fo",
            mode = "n",
            options = { desc = "View old files" },
        },
        {
            action = "<cmd>Telescope quickfix<cr>",
            key = "<leader>fq",
            mode = "n",
            options = { desc = "Search quickfix" },
        },
        {
            action = "<cmd>Telescope registers<cr>",
            key = "<leader>fr",
            mode = "n",
            options = { desc = "View registers" },
        },
        {
            action = "<cmd>Telescope lsp_document_symbols<cr>",
            key = "<leader>fs",
            mode = "n",
            options = { desc = "Search symbols" },
        },
        { action = "<cmd>Telescope live_grep<cr>", key = "<leader>fw", mode = "n", options = { desc = "Live grep" } },
        {
            action = "<cmd>Telescope git_branches<cr>",
            key = "<leader>gB",
            mode = "n",
            options = { desc = "View git branches" },
        },
        {
            action = "<cmd>Telescope git_bcommits<cr>",
            key = "<leader>gC",
            mode = "n",
            options = { desc = "View git bcommits" },
        },
        {
            action = "<cmd>Telescope git_stash<cr>",
            key = "<leader>gS",
            mode = "n",
            options = { desc = "View git stashes" },
        },
        {
            action = "<cmd>Telescope git_commits<cr>",
            key = "<leader>gc",
            mode = "n",
            options = { desc = "View git commits" },
        },
        {
            action = "<cmd>Telescope git_status<cr>",
            key = "<leader>gs",
            mode = "n",
            options = { desc = "View git status" },
        },
        { action = require("harpoon.mark").add_file, key = "<leader>ha", mode = "n", options = { silent = true } },
        {
            action = require("harpoon.ui").toggle_quick_menu,
            key = "<leader>he",
            mode = "n",
            options = { silent = true },
        },
        {
            action = function()
                require("harpoon.ui").nav_file(1)
            end,
            key = "<leader>hj",
            mode = "n",
            options = { silent = true },
        },
        {
            action = function()
                require("harpoon.ui").nav_file(2)
            end,
            key = "<leader>hk",
            mode = "n",
            options = { silent = true },
        },
        {
            action = function()
                require("harpoon.ui").nav_file(3)
            end,
            key = "<leader>hl",
            mode = "n",
            options = { silent = true },
        },
        {
            action = function()
                require("harpoon.ui").nav_file(4)
            end,
            key = "<leader>hm",
            mode = "n",
            options = { silent = true },
        },
        {
            action = function()
                require("yazi").yazi()
            end,
            key = "<leader>e",
            mode = "n",
            options = { desc = "Yazi toggle", silent = true },
        },
        {
            action = ":UndotreeToggle<CR>",
            key = "<leader>uu",
            mode = "n",
            options = { desc = "Undotree toggle", silent = true },
        },
        {
            action = "<cmd>Trouble preview_split toggle<cr>",
            key = "<leader>xx",
            mode = "n",
            options = { desc = "Diagnostics toggle", silent = true },
        },
        {
            action = "<cmd>Trouble preview_split toggle filter.buf=0<cr>",
            key = "<leader>xX",
            mode = "n",
            options = { desc = "Buffer Diagnostics toggle", silent = true },
        },
        {
            action = "<cmd>Trouble symbols toggle focus=false<cr>",
            key = "<leader>us",
            mode = "n",
            options = { desc = "Symbols toggle", silent = true },
        },
        {
            action = "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
            key = "<leader>xl",
            mode = "n",
            options = { desc = "LSP Definitions / references / ... toggle", silent = true },
        },
        {
            action = "<cmd>Trouble loclist toggle<cr>",
            key = "<leader>xL",
            mode = "n",
            options = { desc = "Location List toggle", silent = true },
        },
        {
            action = "<cmd>Trouble qflist toggle<cr>",
            key = "<leader>xQ",
            mode = "n",
            options = { desc = "Quickfix List toggle", silent = true },
        },
        {
            action = ":ToggleTerm<CR>",
            key = "<leader>tt",
            mode = "n",
            options = { desc = "Open Terminal", silent = true },
        },
        {
            action = function()
                local toggleterm = require("toggleterm.terminal")

                toggleterm.Terminal:new({ cmd = "lazygit", hidden = true }):toggle()
            end,
            key = "<leader>tg",
            mode = "n",
            options = { desc = "Open Lazygit", silent = true },
        },
        {
            action = function()
                local toggleterm = require("toggleterm.terminal")

                toggleterm.Terminal:new({ cmd = "lazygit", hidden = true }):toggle()
            end,
            key = "<leader>gg",
            mode = "n",
            options = { desc = "Open Lazygit", silent = true },
        },
        {
            action = function()
                require("telescope.builtin").find_files({
                    prompt_title = "Config Files",
                    cwd = vim.fn.stdpath("config"),
                    follow = true,
                })
            end,
            key = "<leader>fc",
            mode = "n",
            options = { desc = "Find config files", silent = true },
        },
        {
            action = function()
                require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
            end,
            key = "<leader>fF",
            mode = "n",
            options = { desc = "Find all files", silent = true },
        },
        {
            action = function()
                require("telescope.builtin").colorscheme({ enable_preview = true })
            end,
            key = "<leader>fT",
            mode = "n",
            options = { desc = "Find theme", silent = true },
        },
        {
            action = function()
                require("telescope.builtin").live_grep({
                    additional_args = function(args)
                        return vim.list_extend(args, { "--hidden", "--no-ignore" })
                    end,
                })
            end,
            key = "<leader>fW",
            mode = "n",
            options = { desc = "Find words in all files", silent = true },
        },
        {
            action = function()
                require("telescope.builtin").live_grep({ grep_open_files = true })
            end,
            key = "<leader>f?",
            mode = "n",
            options = { desc = "Find words in all open buffers", silent = true },
        },
        {
            action = ":Telescope file_browser<CR>",
            key = "<leader>fe",
            mode = "n",
            options = { desc = "File Explorer", silent = true },
        },
        {
            action = ":Telescope frecency<CR>",
            key = "<leader>fO",
            mode = "n",
            options = { desc = "Find Frequent Files", silent = true },
        },
        {
            action = ":Telescope undo<CR>",
            key = "<leader>fu",
            mode = "n",
            options = { desc = "List undo history", silent = true },
        },
        {
            action = ":Spectre<CR>",
            key = "<leader>rs",
            mode = "n",
            options = { desc = "Spectre toggle", silent = true },
        },
        { action = ":Refactor extract ", key = "<leader>re", mode = "x", options = { desc = "Extract", silent = true } },
        {
            action = ":Refactor extract_to_file ",
            key = "<leader>rE",
            mode = "x",
            options = { desc = "Extract to file", silent = true },
        },
        {
            action = ":Refactor extract_var ",
            key = "<leader>rv",
            mode = "x",
            options = { desc = "Extract var", silent = true },
        },
        {
            action = ":Refactor inline_var<CR>",
            key = "<leader>ri",
            mode = "n",
            options = { desc = "Inline var", silent = true },
        },
        {
            action = ":Refactor inline_func<CR>",
            key = "<leader>rI",
            mode = "n",
            options = { desc = "Inline Func", silent = true },
        },
        {
            action = ":Refactor extract_block<CR>",
            key = "<leader>rb",
            mode = "n",
            options = { desc = "Extract block", silent = true },
        },
        {
            action = ":Refactor extract_block_to_file<CR>",
            key = "<leader>rB",
            mode = "n",
            options = { desc = "Extract block to file", silent = true },
        },
        {
            action = function()
                require("telescope").extensions.refactoring.refactors()
            end,
            key = "<leader>fR",
            mode = "n",
            options = { desc = "Refactoring", silent = true },
        },
        {
            action = ":Telescope projects<CR>",
            key = "<leader>fp",
            mode = "n",
            options = { desc = "Find projects", silent = true },
        },
        {
            action = function()
                if require("precognition").toggle() then
                    vim.notify("precognition on")
                else
                    vim.notify("precognition off")
                end
            end,
            key = "<leader>uP",
            mode = "n",
            options = { desc = "Precognition Toggle", silent = true },
        },
        {
            action = ":Telescope noice<CR>",
            key = "<leader>fn",
            mode = "n",
            options = { desc = "Find notifications", silent = true },
        },
        {
            action = function()
                require("neotest").run.run({ strategy = "dap" })
            end,
            key = "<leader>dn",
            mode = "n",
            options = { desc = "Neotest Debug" },
        },
        { action = "<CMD>Neotest attach<CR>", key = "<leader>na", mode = "n", options = { desc = "Attach" } },
        {
            action = function()
                require("neotest").run.run({ strategy = "dap" })
            end,
            key = "<leader>nd",
            mode = "n",
            options = { desc = "Debug" },
        },
        { action = "<CMD>Neotest output<CR>", key = "<leader>nh", mode = "n", options = { desc = "Output" } },
        {
            action = "<CMD>Neotest output-panel<CR>",
            key = "<leader>no",
            mode = "n",
            options = { desc = "Output Panel toggle" },
        },
        { action = "<CMD>Neotest run<CR>", key = "<leader>nr", mode = "n", options = { desc = "Run (Nearest Test)" } },
        {
            action = function()
                require("neotest").run.run(vim.fn.expand("%"))
            end,
            key = "<leader>nR",
            mode = "n",
            options = { desc = "Run (File)" },
        },
        { action = "<CMD>Neotest stop<CR>", key = "<leader>ns", mode = "n", options = { desc = "Stop" } },
        { action = "<CMD>Neotest summary<CR>", key = "<leader>nt", mode = "n", options = { desc = "Summary toggle" } },
        {
            action = ":Neotree action=focus reveal toggle<CR>",
            key = "<leader>E",
            mode = "n",
            options = { desc = "Explorer toggle", silent = true },
        },
        {
            action = MiniMap.toggle,
            key = "<leader>um",
            mode = "n",
            options = { desc = "MiniMap toggle", silent = true },
        },
        {
            action = MiniDiff.toggle_overlay,
            key = "<leader>ugo",
            mode = "n",
            options = { desc = "Git Overlay toggle", silent = true },
        },
        {
            action = require("mini.bufremove").delete,
            key = "<leader>c",
            mode = "n",
            options = { desc = "Close buffer", silent = true },
        },
        {
            action = require("mini.bufremove").delete,
            key = "<C-w>",
            mode = "n",
            options = { desc = "Close buffer", silent = true },
        },
        {
            action = function()
                local current = vim.api.nvim_get_current_buf()

                local get_listed_bufs = function()
                    return vim.tbl_filter(function(bufnr)
                        return vim.api.nvim_buf_get_option(bufnr, "buflisted")
                    end, vim.api.nvim_list_bufs())
                end

                for _, bufnr in ipairs(get_listed_bufs()) do
                    if bufnr ~= current then
                        require("mini.bufremove").delete(bufnr)
                    end
                end
            end,
            key = "<leader>bc",
            mode = "n",
            options = { desc = "Close all buffers but current" },
        },
        {
            action = ":MarkdownPreview<cr>",
            key = "<leader>pm",
            mode = "n",
            options = { desc = "Markdown Preview", silent = true },
        },
        {
            action = ":IBLToggle<CR>",
            key = "<leader>ui",
            mode = "n",
            options = { desc = "Indent-Blankline toggle", silent = true },
        },
        {
            action = ":IBLToggleScope<CR>",
            key = "<leader>uI",
            mode = "n",
            options = { desc = "Indent-Blankline Scope toggle", silent = true },
        },
        {
            action = function()
                require("hop").hint_char1({
                    direction = require("hop.hint").HintDirection.AFTER_CURSOR,
                })
            end,
            key = "f",
            mode = "",
            options = { remap = true },
        },
        {
            action = function()
                require("hop").hint_char1({
                    direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
                })
            end,
            key = "F",
            mode = "",
            options = { remap = true },
        },
        {
            action = function()
                require("hop").hint_char1({
                    direction = require("hop.hint").HintDirection.AFTER_CURSOR,
                    hint_offset = -1,
                })
            end,
            key = "t",
            mode = "",
            options = { remap = true },
        },
        {
            action = function()
                require("hop").hint_char1({
                    direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
                    hint_offset = 1,
                })
            end,
            key = "T",
            mode = "",
            options = { remap = true },
        },
        { action = ":Glow<CR>", key = "<leader>pg", mode = "n", options = { desc = "Glow (Markdown)", silent = true } },
        {
            action = ":Gitsigns toggle_current_line_blame<CR>",
            key = "<leader>ugb",
            mode = "n",
            options = { desc = "Git Blame toggle", silent = true },
        },
        {
            action = ":Gitsigns toggle_deleted<CR>",
            key = "<leader>ugd",
            mode = "n",
            options = { desc = "Deleted toggle", silent = true },
        },
        {
            action = ":Gitsigns toggle_linehl<CR>",
            key = "<leader>ugl",
            mode = "n",
            options = { desc = "Line Highlight toggle", silent = true },
        },
        {
            action = ":Gitsigns toggle_numhl<CR>",
            key = "<leader>ugh",
            mode = "n",
            options = { desc = "Number Highlight toggle", silent = true },
        },
        {
            action = "<cmd>Gitsigns toggle_word_diff<CR>",
            key = "<leader>ugw",
            mode = "n",
            options = { desc = "Word Diff toggle", silent = true },
        },
        {
            action = "<cmd>Gitsigns toggle_signs<CR>",
            key = "<leader>ugs",
            mode = "n",
            options = { desc = "Signs toggle", silent = true },
        },
        {
            action = function()
                require("gitsigns").blame_line({ full = true })
            end,
            key = "<leader>gb",
            mode = "n",
            options = { desc = "Git Blame toggle", silent = true },
        },
        {
            action = function()
                if vim.wo.diff then
                    return "<leader>gp"
                end

                vim.schedule(function()
                    require("gitsigns").prev_hunk()
                end)

                return "<Ignore>"
            end,
            key = "<leader>ghp",
            mode = "n",
            options = { desc = "Previous hunk", silent = true },
        },
        {
            action = function()
                if vim.wo.diff then
                    return "<leader>gn"
                end

                vim.schedule(function()
                    require("gitsigns").next_hunk()
                end)

                return "<Ignore>"
            end,
            key = "<leader>ghn",
            mode = "n",
            options = { desc = "Next hunk", silent = true },
        },
        {
            action = "<cmd>Gitsigns stage_hunk<CR>",
            key = "<leader>ghs",
            mode = { "n", "v" },
            options = { desc = "Stage hunk", silent = true },
        },
        {
            action = "<cmd>Gitsigns undo_stage_hunk<CR>",
            key = "<leader>ghu",
            mode = "n",
            options = { desc = "Undo stage hunk", silent = true },
        },
        {
            action = "<cmd>Gitsigns reset_hunk<CR>",
            key = "<leader>ghr",
            mode = { "n", "v" },
            options = { desc = "Reset hunk", silent = true },
        },
        {
            action = "<cmd>Gitsigns preview_hunk<CR>",
            key = "<leader>ghP",
            mode = "n",
            options = { desc = "Preview hunk", silent = true },
        },
        {
            action = "<cmd>Gitsigns preview_hunk_inline<CR>",
            key = "<leader>gh<C-p>",
            mode = "n",
            options = { desc = "Preview hunk inline", silent = true },
        },
        {
            action = "<cmd>Gitsigns stage_buffer<CR>",
            key = "<leader>gS",
            mode = "n",
            options = { desc = "Stage buffer", silent = true },
        },
        {
            action = "<cmd>Gitsigns reset_buffer<CR>",
            key = "<leader>gR",
            mode = "n",
            options = { desc = "Reset buffer", silent = true },
        },
        {
            action = require("gitignore").generate,
            key = "<leader>gi",
            mode = "n",
            options = { desc = "Gitignore generate", silent = true },
        },
        {
            action = ":Telescope git_worktree<CR>",
            key = "<leader>fg",
            mode = "n",
            options = { desc = "Git Worktree", silent = true },
        },
        {
            action = function()
                require("telescope").extensions.git_worktree.create_git_worktree()
            end,
            key = "<leader>gWc",
            mode = "n",
            options = { desc = "Create worktree", silent = true },
        },
        {
            action = function()
                require("telescope").extensions.git_worktree.git_worktrees()
            end,
            key = "<leader>gWs",
            mode = "n",
            options = { desc = "Switch / Delete worktree", silent = true },
        },
        {
            action = function()
                vim.g.diffview_enabled = not vim.g.diffview_enabled
                if vim.g.diffview_enabled then
                    vim.cmd("DiffviewClose")
                else
                    vim.cmd("DiffviewOpen")
                end
            end,
            key = "<leader>gd",
            mode = "n",
            options = { desc = "Git Diff toggle", silent = true },
        },
        {
            action = function()
                require("dap").toggle_breakpoint()
            end,
            key = "<leader>db",
            mode = "n",
            options = { desc = "Breakpoint toggle", silent = true },
        },
        {
            action = function()
                require("dap").continue()
            end,
            key = "<leader>dc",
            mode = "n",
            options = { desc = "Continue Debugging (Start)", silent = true },
        },
        {
            action = function()
                require("dapui").eval()
            end,
            key = "<leader>de",
            mode = "v",
            options = { desc = "Evaluate Input", silent = true },
        },
        {
            action = function()
                vim.ui.input({ prompt = "Expression: " }, function(expr)
                    if expr then
                        require("dapui").eval(expr, { enter = true })
                    end
                end)
            end,
            key = "<leader>de",
            mode = "n",
            options = { desc = "Evaluate Input", silent = true },
        },
        {
            action = function()
                require("dap.ui.widgets").hover()
            end,
            key = "<leader>dh",
            mode = "n",
            options = { desc = "Debugger Hover", silent = true },
        },
        {
            action = function()
                require("dap").step_out()
            end,
            key = "<leader>do",
            mode = "n",
            options = { desc = "Step Out", silent = true },
        },
        {
            action = function()
                require("dap").step_over()
            end,
            key = "<leader>ds",
            mode = "n",
            options = { desc = "Step Over", silent = true },
        },
        {
            action = function()
                require("dap").step_into()
            end,
            key = "<leader>dS",
            mode = "n",
            options = { desc = "Step Into", silent = true },
        },
        {
            action = function()
                require("dap").terminate()
            end,
            key = "<leader>dt",
            mode = "n",
            options = { desc = "Terminate Debugging", silent = true },
        },
        {
            action = function()
                require("dap.ext.vscode").load_launchjs(nil, {})
                require("dapui").toggle()
            end,
            key = "<leader>du",
            mode = "n",
            options = { desc = "Toggle Debugger UI", silent = true },
        },
        { action = "<cmd>CBd<cr>", key = "<leader>lcd", mode = "n", options = { desc = "Delete a box" } },
        { action = "<cmd>CBccbox<cr>", key = "<leader>lcb", mode = "n", options = { desc = "Box Title" } },
        { action = "<cmd>CBllline<cr>", key = "<leader>lct", mode = "n", options = { desc = "Titled Line" } },
        { action = "<cmd>CBline<cr>", key = "<leader>lcl", mode = "n", options = { desc = "Simple Line" } },
        { action = ":CodeSnap<CR>", key = "<leader>cs", mode = "v", options = { desc = "Copy", silent = true } },
        { action = ":CodeSnapSave<CR>", key = "<leader>cS", mode = "v", options = { desc = "Save", silent = true } },
        {
            action = ":CodeSnapHighlight<CR>",
            key = "<leader>ch",
            mode = "v",
            options = { desc = "Highlight", silent = true },
        },
        {
            action = ":CodeSnapSaveHighlight<CR>",
            key = "<leader>cH",
            mode = "v",
            options = { desc = "Save Highlight", silent = true },
        },
        {
            action = ":Codeium Chat<CR>",
            key = "<leader>uc",
            mode = "n",
            options = { desc = "Codeium Chat", silent = true },
        },
        {
            action = ":CccPick<CR>",
            key = "<leader>up",
            mode = "n",
            options = { desc = "Color Picker toggle", silent = true },
        },
        {
            action = ":BufferLineTogglePin<cr>",
            key = "<leader>bP",
            mode = "n",
            options = { desc = "Pin buffer toggle", silent = true },
        },
        {
            action = ":BufferLinePick<cr>",
            key = "<leader>bp",
            mode = "n",
            options = { desc = "Pick Buffer", silent = true },
        },
        {
            action = ":BufferLineSortByDirectory<cr>",
            key = "<leader>bsd",
            mode = "n",
            options = { desc = "Sort By Directory", silent = true },
        },
        {
            action = ":BufferLineSortByExtension<cr>",
            key = "<leader>bse",
            mode = "n",
            options = { desc = "Sort By Extension", silent = true },
        },
        {
            action = ":BufferLineSortByRelativeDirectory<cr>",
            key = "<leader>bsr",
            mode = "n",
            options = { desc = "Sort By Relative Directory", silent = true },
        },
        { action = "<BS>x", key = "<BS>", mode = "n", options = { silent = true } },
        { action = ":resize +2<CR>", key = "<C-Down>", mode = "n", options = { silent = true } },
        { action = ":vertical resize +2<CR>", key = "<C-Left>", mode = "n", options = { silent = true } },
        { action = ":vertical resize -2<CR>", key = "<C-Right>", mode = "n", options = { silent = true } },
        { action = ":resize -2<CR>", key = "<C-Up>", mode = "n", options = { silent = true } },
        { action = ":b#<CR>", key = "<C-c>", mode = "n", options = { silent = true } },
        { action = ":cprev<CR>", key = "<C-j>", mode = "n", options = { silent = true } },
        { action = ":cnext<CR>", key = "<C-k>", mode = "n", options = { silent = true } },
        { action = "<Cmd>enew<CR>", key = "<C-n>", mode = "n", options = { desc = "New file", silent = true } },
        { action = "<Cmd>confirm q<CR>", key = "<Leader>q", mode = "n", options = { desc = "Quit", silent = true } },
        { action = "<Cmd>w<CR>", key = "<Leader>w", mode = "n", options = { desc = "Save", silent = true } },
        { action = ":move+<CR>", key = "<M-j>", mode = "n", options = { silent = true } },
        { action = ":move-2<CR>", key = "<M-k>", mode = "n", options = { silent = true } },
        {
            action = ":bprevious<CR>",
            key = "<S-TAB>",
            mode = "n",
            options = { desc = "Previous buffer", silent = true },
        },
        { action = "<NOP>", key = "<Space>", mode = "n", options = { silent = true } },
        {
            action = ":bnext<CR>",
            key = "<TAB>",
            mode = "n",
            options = { desc = "Next buffer (default)", silent = true },
        },
        { action = ":noh<CR>", key = "<esc>", mode = "n", options = { silent = true } },
        { action = "<Cmd>q!<CR>", key = "<leader>Q", mode = "n", options = { desc = "Force quit", silent = true } },
        { action = "<Cmd>w!<CR>", key = "<leader>W", mode = "n", options = { desc = "Force write", silent = true } },
        { action = "<C-w>h", key = "<leader>[", mode = "n", options = { desc = "Left window", silent = true } },
        { action = "<C-w>l", key = "<leader>]", mode = "n", options = { desc = "Right window", silent = true } },
        {
            action = ":%bd!<CR>",
            key = "<leader>bC",
            mode = "n",
            options = { desc = "Close all buffers", silent = true },
        },
        {
            action = ":bprevious<CR>",
            key = "<leader>b[",
            mode = "n",
            options = { desc = "Previous buffer", silent = true },
        },
        { action = ":bnext<CR>", key = "<leader>b]", mode = "n", options = { desc = "Next buffer", silent = true } },
        {
            action = function()
                vim.g.disable_diagnostics = not vim.g.disable_diagnostics
                if vim.g.disable_diagnostics then
                    vim.diagnostic.disable()
                else
                    vim.diagnostic.enable()
                end
                vim.notify(string.format("Global Diagnostics %s", bool2str(not vim.g.disable_diagnostics), "info"))
            end,
            key = "<leader>uD",
            mode = "n",
            options = { desc = "Global Diagnostics toggle", silent = true },
        },
        {
            action = function()
                -- vim.g.disable_autoformat = not vim.g.disable_autoformat
                vim.cmd("FormatToggle")
                vim.notify(string.format("Global Autoformatting %s", bool2str(not vim.g.disable_autoformat), "info"))
            end,
            key = "<leader>uF",
            mode = "n",
            options = { desc = "Global Autoformatting toggle", silent = true },
        },
        {
            action = function()
                if vim.g.spell_enabled then
                    vim.cmd("setlocal nospell")
                end
                if not vim.g.spell_enabled then
                    vim.cmd("setlocal spell")
                end
                vim.g.spell_enabled = not vim.g.spell_enabled
                vim.notify(string.format("Spell %s", bool2str(vim.g.spell_enabled), "info"))
            end,
            key = "<leader>uS",
            mode = "n",
            options = { desc = "Spell toggle", silent = true },
        },
        {
            action = function()
                vim.g.cmp_enabled = not vim.g.cmp_enabled
                vim.notify(string.format("Completions %s", bool2str(vim.g.cmp_enabled), "info"))
            end,
            key = "<leader>uc",
            mode = "n",
            options = { desc = "Completions toggle", silent = true },
        },
        {
            action = function()
                vim.b.disable_diagnostics = not vim.b.disable_diagnostics
                if vim.b.disable_diagnostics then
                    vim.diagnostic.disable(0)
                else
                    vim.diagnostic.enable(0)
                end
                vim.notify(string.format("Buffer Diagnostics %s", bool2str(not vim.b.disable_diagnostics), "info"))
            end,
            key = "<leader>ud",
            mode = "n",
            options = { desc = "Buffer Diagnostics toggle", silent = true },
        },
        {
            action = function()
                -- vim.g.disable_autoformat = not vim.g.disable_autoformat
                vim.cmd("FormatToggle!")
                vim.notify(string.format("Buffer Autoformatting %s", bool2str(not vim.b[0].disable_autoformat), "info"))
            end,
            key = "<leader>uf",
            mode = "n",
            options = { desc = "Buffer Autoformatting toggle", silent = true },
        },
        {
            action = function()
                local curr_foldcolumn = vim.wo.foldcolumn
                if curr_foldcolumn ~= "0" then
                    vim.g.last_active_foldcolumn = curr_foldcolumn
                end
                vim.wo.foldcolumn = curr_foldcolumn == "0" and (vim.g.last_active_foldcolumn or "1") or "0"
                vim.notify(string.format("Fold Column %s", bool2str(vim.wo.foldcolumn), "info"))
            end,
            key = "<leader>uh",
            mode = "n",
            options = { desc = "Fold Column toggle", silent = true },
        },
        {
            action = function()
                vim.wo.wrap = not vim.wo.wrap
                vim.notify(string.format("Wrap %s", bool2str(vim.wo.wrap), "info"))
            end,
            key = "<leader>uw",
            mode = "n",
            options = { desc = "Word Wrap toggle", silent = true },
        },
        { action = "y$", key = "Y", mode = "n", options = { silent = true } },
        { action = "<Cmd>split<CR>", key = "\\", mode = "n", options = { desc = "Horizontal split", silent = true } },
        {
            action = "v:count == 0 ? 'gj' : 'j'",
            key = "j",
            mode = "n",
            options = { desc = "Move cursor down", expr = true, silent = true },
        },
        {
            action = "v:count == 0 ? 'gk' : 'k'",
            key = "k",
            mode = "n",
            options = { desc = "Move cursor up", expr = true, silent = true },
        },
        { action = "<Cmd>vsplit<CR>", key = "|", mode = "n", options = { desc = "Vertical split", silent = true } },
        { action = "<gv", key = "<", mode = "v", options = { desc = "Unindent line", silent = true } },
        { action = "x", key = "<BS>", mode = "v", options = { silent = true } },
        { action = "<gv", key = "<S-Tab>", mode = "v", options = { desc = "Unindent line", silent = true } },
        { action = ">gv", key = "<Tab>", mode = "v", options = { desc = "Indent line", silent = true } },
        { action = ">gv", key = ">", mode = "v", options = { desc = "Indent line", silent = true } },
        { action = ":m '>+1<CR>gv=gv", key = "J", mode = "v", options = { silent = true } },
        { action = ":m '<-2<CR>gv=gv", key = "K", mode = "v", options = { silent = true } },
        { action = "<Left>", key = "<C-h>", mode = "i", options = { silent = true } },
        { action = "<C-o>gj", key = "<C-j>", mode = "i", options = { silent = true } },
        { action = "<C-o>gk", key = "<C-k>", mode = "i", options = { silent = true } },
        { action = "<Right>", key = "<C-l>", mode = "i", options = { silent = true } },
    }
    for i, map in ipairs(__nixvim_binds) do
        vim.keymap.set(map.mode, map.key, map.action, map.options)
    end
end
-- }}}

vim.filetype.add({
    extension = { avsc = "json", http = "http", ignore = "gitignore", rasi = "scss" },
    pattern = { [".*/hypr/.*%.conf"] = "hyprlang", [".*helm-chart*.yaml"] = "helm", ["flake.lock"] = "json" },
})

-- Set up autogroups {{
do
    local __nixvim_autogroups = { nixvim_binds_LspAttach = { clear = true } }

    for group_name, options in pairs(__nixvim_autogroups) do
        vim.api.nvim_create_augroup(group_name, options)
    end
end
-- }}
-- Set up autocommands {{
do
    local __nixvim_autocommands = {
        {
            callback = function()
                require("jdtls").start_or_attach({
                    cmd = {
                        "/nix/store/81j7fggnmmnnkh10grl4q5xvd4z9arg9-jdt-language-server-1.38.0/bin/jdtls",
                        "-data",
                        vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t"),
                        "-configuration",
                        "$XDG_CACHE_HOME/jdtls/config",
                    },
                })
            end,
            event = "FileType",
            pattern = "java",
        },
        {
            callback = function()
                do
                    local __nixvim_binds = {
                        {
                            action = vim.diagnostic.open_float,
                            key = "<leader>lH",
                            mode = "n",
                            options = { silent = true },
                        },
                        {
                            action = vim.diagnostic.goto_prev,
                            key = "<leader>l[",
                            mode = "n",
                            options = { silent = true },
                        },
                        {
                            action = vim.diagnostic.goto_next,
                            key = "<leader>l]",
                            mode = "n",
                            options = { silent = true },
                        },
                        { action = vim.lsp.buf.references, key = "<leader>lD", mode = "n", options = { silent = true } },
                        {
                            action = vim.lsp.buf.code_action,
                            key = "<leader>la",
                            mode = "n",
                            options = { silent = true },
                        },
                        { action = vim.lsp.buf.definition, key = "<leader>ld", mode = "n", options = { silent = true } },
                        { action = vim.lsp.buf.format, key = "<leader>lf", mode = "n", options = { silent = true } },
                        { action = vim.lsp.buf.hover, key = "<leader>lh", mode = "n", options = { silent = true } },
                        {
                            action = vim.lsp.buf.implementation,
                            key = "<leader>li",
                            mode = "n",
                            options = { silent = true },
                        },
                        { action = vim.lsp.buf.rename, key = "<leader>lr", mode = "n", options = { silent = true } },
                        {
                            action = vim.lsp.buf.type_definition,
                            key = "<leader>lt",
                            mode = "n",
                            options = { silent = true },
                        },
                        {
                            action = function()
                                vim.lsp.buf.format({
                                    async = true,
                                    range = {
                                        ["start"] = vim.api.nvim_buf_get_mark(0, "<"),
                                        ["end"] = vim.api.nvim_buf_get_mark(0, ">"),
                                    },
                                })
                            end,
                            key = "<leader>lf",
                            mode = "v",
                            options = { desc = "Format selection" },
                        },
                        {
                            action = peek_definition,
                            key = "<leader>lp",
                            mode = "n",
                            options = { desc = "Preview definition" },
                        },
                        {
                            action = peek_type_definition,
                            key = "<leader>lP",
                            mode = "n",
                            options = { desc = "Preview type definition" },
                        },
                    }
                    for i, map in ipairs(__nixvim_binds) do
                        vim.keymap.set(map.mode, map.key, map.action, map.options)
                    end
                end
            end,
            desc = "Load keymaps for LspAttach",
            event = "LspAttach",
            group = "nixvim_binds_LspAttach",
        },
        { command = "setlocal conceallevel=1", event = "FileType", pattern = "norg" },
        { command = "normal gg=G``zz", event = "BufWritePre", pattern = "*.norg" },
        {
            callback = function()
                vim.b.miniindentscope_disable = true
            end,
            event = { "FileType" },
            pattern = {
                "help",
                "alpha",
                "dashboard",
                "neo-tree",
                "Trouble",
                "trouble",
                "lazy",
                "mason",
                "notify",
                "toggleterm",
                "lazyterm",
            },
        },
        { command = "LspRestart", event = "FileType", pattern = "helm" },
        {
            callback = function(event)
                local client = vim.api.nvim_get_chan_info(vim.v.event.chan).client
                if client ~= nil and client.name == "Firenvim" then
                    vim.o.laststatus = 0
                    vim.o.showtabline = 0
                    require("lualine").hide()
                    local ok, _ = pcall(vim.cmd, "colorscheme sorbet")
                end
            end,
            event = "UIEnter",
        },
        { command = "%s/\\s\\+$//e", event = "BufWrite" },
        {
            callback = function()
                local buf_size_limit = 1024 * 1024 -- 1MB size limit
                if vim.api.nvim_buf_get_offset(0, vim.api.nvim_buf_line_count(0)) > buf_size_limit then
                    require("ibl").setup_buffer(0, { enabled = false })
                    vim.b.miniindentscope_disable = true
                    require("illuminate").pause_buf()

                    -- Disable line numbers and relative line numbers
                    vim.cmd("setlocal nonumber norelativenumber")

                    -- Disable syntax highlighting
                    -- vim.cmd("syntax off")

                    -- Disable matchparen
                    vim.cmd("let g:loaded_matchparen = 1")

                    -- Disable cursor line and column
                    vim.cmd("setlocal nocursorline nocursorcolumn")

                    -- Disable folding
                    vim.cmd("setlocal nofoldenable")

                    -- Disable sign column
                    vim.cmd("setlocal signcolumn=no")

                    -- Disable swap file and undo file
                    vim.cmd("setlocal noswapfile noundofile")
                end
            end,
            event = "BufEnter",
            pattern = { "*" },
        },
        { command = "setlocal spell spelllang=en_us", event = "FileType", pattern = { "tex", "latex", "markdown" } },
    }

    for _, autocmd in ipairs(__nixvim_autocommands) do
        vim.api.nvim_create_autocmd(autocmd.event, {
            group = autocmd.group,
            pattern = autocmd.pattern,
            buffer = autocmd.buffer,
            desc = autocmd.desc,
            callback = autocmd.callback,
            command = autocmd.command,
            once = autocmd.once,
            nested = autocmd.nested,
        })
    end
end
-- }}

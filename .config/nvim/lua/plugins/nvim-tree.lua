local api = require("nvim-tree.api")

require("nvim-tree").setup({
    hijack_netrw = true,
    hijack_cursor = true,
    actions = {
        change_dir = {
            enable = true,
            restrict_above_cwd = true,
        },
    },
    renderer = {
        root_folder_label = false,
        indent_markers = {
            enable = true, -- включает линии отступа (вложенности)
            inline_arrows = true, -- стрелки папок будут на одной линии с маркерами (рекомендуется)
            icons = {
                corner = "└", -- символ нижнего угла
                edge = "│", -- символ вертикальной линии
                item = "├",
                bottom = "─",
                none = " ",
            },
        },
        icons = {
            git_placement = "right_align",
            web_devicons = {
                file = { enable = true, color = true }, -- включение файловых декораторов
                folder = { enable = true, color = true }, -- включение декораторов папок
            },
            show = {
                file = true,
                folder = true,
                folder_arrow = false, -- включает декоратор стрелочки у папки
            },
            -- glyphs = {
            --     folder = {
            --         arrow_closed = "🖈", -- или ""
            --         arrow_open = "📂",   -- или ""
            --         default = "  ",      -- базовая иконка закрытой папки из snacks
            --         open = "  ",         -- иконка открытой папки из snacks
            --         empty = "  ",        -- пустая папка
            --         empty_open = "  ",   -- открытая пустая папка
            --         symlink = "",
            --         symlink_open = "",
            --     },
            -- },
        },
    },
    view = {
        preserve_window_proportions = true,
        adaptive_size=true,
        -- width = 30, 
    },
    on_attach = function (bufnr)
        local opts = { buffer = bufnr }
        api.config.mappings.default_on_attach(bufnr)

        -- Кастомная функция открытия
        local function smart_open()
            local node = api.tree.get_node_under_cursor()

            -- Если это файл, проверяем ширину
            if node.type == "file" then
                local screen_width = vim.opt.columns:get()
                local win_width = vim.api.nvim_win_get_width(0)
                local ratio = win_width / screen_width

                -- Открываем файл
                api.node.open.edit()

                -- Если ширина > 25%, закрываем дерево
                if win_width > (screen_width * 0.25) then
                    api.tree.close()
                end
            else
                -- Если это папка, просто открываем/закрываем её
                api.node.open.edit()
            end
        end

        local ng = require("custom.angular")

        local function grip()
            local node = api.tree.get_node_under_cursor()

            -- Проверяем, что под курсором файл, а не папка
            if node and node.type == "file" then
                -- Получаем относительный путь файла от корня проекта
                local relative_path = vim.fn.fnamemodify(node.absolute_path, ":.")

                -- Выполняем команду Neovim: Grip ./относительный_путь
                vim.cmd("Grip ./" .. relative_path)
            else
                vim.notify("Grip можно запустить только для файлов", vim.log.levels.WARN)
            end
        end

        local function get_cursor_dir()
            local node = api.tree.get_node_under_cursor()
            if node.type == "directory" then
                return node.absolute_path
            end
            return vim.fs.dirname(node.absolute_path)
        end

        local function files_find_under_cursor()
            Snacks.picker.files({ cwd = get_cursor_dir() })
        end

        local function grep_under_cursor()
            Snacks.picker.grep({ cwd = get_cursor_dir() })
        end

        local mappings = {
            -- BEGIN_DEFAULT_ON_ATTACH
            -- ["C"] = { api.tree.change_root_to_node, "CD" },
            -- ["<C-e>"] = { api.node.open.replace_tree_buffer, "Open: In Place" },
            ["<C-e>"] = { function () vim.cmd("wincmd p") end, "Return to editor" },
            ["<C-k>"] = { api.node.show_info_popup, "Info" },
            ["<C-r>"] = { api.fs.rename_sub, "Rename: Omit Filename" },
            ["<C-t>"] = { api.node.open.tab, "Open: New Tab" },
            ["<C-v>"] = { api.node.open.vertical, "Open: Vertical Split" },
            ["<C-x>"] = { api.node.open.horizontal, "Open: Horizontal Split" },
            ["<BS>"] = { api.node.navigate.parent_close, "Close Directory" },
            ["<leader><space>"] = { files_find_under_cursor, "Files Find (cursor dir)" },
            ["<leader>/"] = { grep_under_cursor, "Grep (cursor dir)" },
            ["<CR>"] = { api.node.open.edit, "Open" },
            ["<Tab>"] = { api.node.open.preview, "Open Preview" },
            [">"] = { api.node.navigate.sibling.next, "Next Sibling" },
            ["<"] = { api.node.navigate.sibling.prev, "Previous Sibling" },
            ["."] = { api.node.run.cmd, "Run Command" },
            ["-"] = { api.tree.change_root_to_parent, "Up" },
            ["a"] = { api.fs.create, "Create" },
            ["bmv"] = { api.marks.bulk.move, "Move Bookmarked" },
            ["B"] = { api.tree.toggle_no_buffer_filter, "Toggle No Buffer" },
            ["C"] = { api.tree.toggle_git_clean_filter, "Toggle Git Clean" },
            ["[c"] = { api.node.navigate.git.prev, "Prev Git" },
            ["]c"] = { api.node.navigate.git.next, "Next Git" },
            ["E"] = { api.tree.expand_all, "Expand All" },
            ["e"] = { api.fs.rename_basename, "Rename: Basename" },
            ["]e"] = { api.node.navigate.diagnostics.next, "Next Diagnostic" },
            ["[e"] = { api.node.navigate.diagnostics.prev, "Prev Diagnostic" },
            ["F"] = { api.live_filter.clear, "Clean Filter" },
            ["f"] = { api.live_filter.start, "Filter" },
            ["g?"] = { api.tree.toggle_help, "Help" },
            ["H"] = { api.tree.toggle_hidden_filter, "Toggle Dotfiles" },
            ["I"] = { api.tree.toggle_gitignore_filter, "Toggle Git Ignore" },
            ["J"] = { api.node.navigate.sibling.last, "Last Sibling" },
            ["K"] = { api.node.navigate.sibling.first, "First Sibling" },
            ["m"] = { api.marks.toggle, "Toggle Bookmark" },
            ["o"] = { api.node.open.edit, "Open" },
            -- ["O"] = { api.node.open.no_window_picker, "Open: No Window Picker" },
            ["O"] = { grip, "Help" },
            ["p"] = { api.fs.paste, "Paste" },
            ["P"] = { api.node.navigate.parent, "Parent Directory" },
            ["q"] = { api.tree.close, "Close" },
            ["r"] = { api.fs.rename, "Rename" },
            ["R"] = { api.tree.reload, "Refresh" },
            ["s"] = { api.node.run.system, "Run System" },
            ["S"] = { api.tree.search_node, "Search" },
            ["U"] = { api.tree.toggle_custom_filter, "Toggle Hidden" },
            ["W"] = { api.tree.collapse_all, "Collapse" },
            ["x"] = { api.fs.cut, "Cut" },
            ["d"] = { api.fs.remove, "Delete" },
            ["D"] = { api.fs.trash, "Trash" },
            ["yy"] = { api.fs.copy.node, "Copy" },
            ["ya"] = { api.fs.copy.absolute_path, "Copy Absolute Path" },
            ["yr"] = { api.fs.copy.relative_path, "Copy Relative Path" },
            ["yn"] = { api.fs.copy.filename, "Copy Name" },
            ["yaw"] = { api.fs.copy.filename, "Copy File Name" },
            ["yiw"] = { api.fs.copy.basename, "Copy Base Name" },
            ["<2-LeftMouse>"] = { api.node.open.edit, "Open" },
            ["<2-RightMouse>"] = { api.tree.change_root_to_node, "CD" },
            -- END_DEFAULT_ON_ATTACH

            -- Mappings migrated from view.mappings.list
            ["l"] = { smart_open, "Open" },
            ["h"] = { api.node.navigate.parent_close, "Close Directory" },
            ["v"] = { api.node.open.vertical, "Open: Vertical Split" },

            -- angular keybinds
            ['ngg'] = { ng.ng_generate, "Angular Schematics (Telescope)" },
            ['ngs'] = { ng.run_schematic, "Angular Schematics (Telescope)" },
        }

        for keys, mapping in pairs(mappings) do
            vim.keymap.set("n", keys, mapping[1], opts)
        end

        -- local function visual_action(func)
        --     local start_line = vim.fn.line("'<")
        --     local end_line = vim.fn.line("'>")
        --     local result = {}
        --
        --     for line = start_line, end_line do
        --         local node = api.tree.get_node_by_line(line)
        --         if node and node.name ~= ".." then
        --             local node_result = func(node.absolute_path)
        --             table.insert(result, node_result)
        --         end
        --     end
        --
        --     -- Join paths by newlines and copy to the system clipboard (+)
        --     if #result > 0 then
        --         local result = table.concat(result, "\n")
        --         vim.fn.setreg("+", result)
        --         print("Copied " .. #result .. " relative paths!")
        --     end
        -- end
        --
        -- for keys, mapping in pairs(mappings) do
        --     vim.keymap.set("v", keys, visual_action(mapping[1]), opts)
        -- end

   end,
})



local al_lsps = {}
local al_filetypes = {
    ["al"] = true;
}


local path_sep = vim.loop.os_uname().sysname == "Windows" and "\\" or "/"

local function path_join(...)
	return table.concat(vim.tbl_flatten {...}, path_sep)
end

local function dirname(filepath)
	local is_changed = false
	local result = filepath:gsub(path_sep.."([^"..path_sep.."]+)$", function()
		is_changed = true
    	return ""
	end)
  	return result, is_changed
end

local bin_folder = vim.loop.os_uname().sysname == "Windows" and "" or "darwin"

local al_lsp_config = {
    name = "al";
    cmd = { path_join(os.getenv("HOME"),
        ".vscode",
		"extensions",
		"ms-dynamics-smb.al-9.5.674382", -- TODO: Make dynamic to get latest version
		"bin",
		bin_folder,
        "Microsoft.Dynamics.Nav.EditorServices.Host")
    };
}

local function buffer_find_root_dir(bufnr, is_root_path)
    local bufname = vim.api.nvim_buf_get_name(bufnr)

    if vim.fn.filereadable(bufname) == 0 then
        return nil
    end

    local dir = bufname

    for _ = 1, 100 do
        local did_change
        dir, did_change = dirname(dir)
        if is_root_path(dir, bufname) then
            return dir, bufname
        end
        if not did_change then
            return nil
        end
    end
end

function check_start_al_lsp()
    local bufnr = vim.api.nvim_get_current_buf()
    if not al_filetypes[vim.api.nvim_buf_get_option(bufnr, 'filetype')] then
        return
    end
    
    local root_dir = buffer_find_root_dir(bufnr, function(dir)
        return vim.fn.filereadable(path_join(dir, 'app.json')) == 1
    end)

    if not root_dir then return end

    local client_id = al_lsps[root_dir]
    if not client_id then
        local new_conf = vim.tbl_extend("error", al_lsp_config, {
            root_dir = root_dir;
        })
        client_id = vim.lsp.start_client(new_conf)
        al_lsps[root_dir] = client_id
    end
    
    vim.lsp.buf_attach_client(bufnr, client_id)
end

return {
	al_neovim = check_start_al_lsp
}


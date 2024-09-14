local M = {}


function M.run_command(command)
  -- Get the git remotes which we can use for the base github url (and maybe other hosts...?)
  local output = vim.fn.system(command)
  if vim.v.shell_error ~= 0 then
      -- Handle errors if the command fails
      vim.notify("Failed to run command", vim.log.levels.ERROR)
      return nil
  end
  return output

end


function M.open_link_in_browser(link)
  -- Check for the platform and open the link using the appropriate command
  local open_cmd
  if vim.fn.has("macunix") == 1 then
    open_cmd = "open"
  elseif vim.fn.has("unix") == 1 then
    open_cmd = "xdg-open"
  elseif vim.fn.has("win32") == 1 then
    open_cmd = "start"
  else
    vim.api.nvim_err_writeln("Unsupported system for opening links.")
    return
  end

  -- Construct the command to open the link in the default browser
  local cmd = open_cmd .. " '" .. link .. "'"

  -- Execute the command
  os.execute(cmd)
end


return M

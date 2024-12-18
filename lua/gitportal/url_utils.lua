local cli = require("gitportal.cli")

local M = {}

local function parse_line_range(url)
    -- Given a url, parse the optional line range from the end of the URL itself.
    -- These may looks like #L5-L11 or #L5-11, or may not be present at all.
    local start_line = nil
    local end_line = nil

    -- TODO: Is this robust enough?
    if string.find(url, "#L", 0, true) ~= nil then
        start_line = url:match("#L(%d+)")
        if string.find(url, "-", 0, true) ~= nil then
            end_line = url:match("#L%d+%-L?(%d+)$")
        end
    end

    if start_line ~= nil then
        if end_line == nil then
            end_line = start_line
        end
        start_line = tonumber(start_line)
        end_line = tonumber(end_line)
    end
    return start_line, end_line
end

local function parse_github_url(url)
    -- a GitHub url may appear as follows... (Check tests for more variants)
    -- https://github.com/trevorhauter/gitportal.nvim/blob/main/lua/gitportal/cli.lua#L45-L55
    local repo, branch_or_commit, file_path = url:match("github.com/[^/]+/([^/]+)/blob/([^/]+)/([^\n#]+)")
    return repo, branch_or_commit, file_path
end

local function parse_gitlab_url(url)
    -- a GitLab url may appear as follows... (Check tests for more variants)
    -- https://gitlab.com/gitportal/gitlab-test/-/blob/master/public/index.html?ref_type=heads#L5-11
    local repo, branch_or_commit, file_path = url:match("gitlab.com/[^/]+/([^/]+)/%-?/?blob/([^/]+)/([^\n%?#]+)")
    return repo, branch_or_commit, file_path
end

function M.parse_githost_url(url)
    local githost_parse_func

    if string.find(url, "github") ~= nil then
        githost_parse_func = parse_github_url
    elseif string.find(url, "gitlab") ~= nil then
        githost_parse_func = parse_gitlab_url
    else
        cli.log_error("Could not determine valid githost from url!")
    end

    local repo, branch_or_commit, file_path = githost_parse_func(url)
    local start_line, end_line = parse_line_range(url)

    return {
        repo = repo,
        branch_or_commit = branch_or_commit,
        file_path = file_path,
        start_line = start_line,
        end_line = end_line,
    }
end

return M

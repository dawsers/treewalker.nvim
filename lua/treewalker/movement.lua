local operations = require "treewalker.operations"
local targets = require "treewalker.targets"
local nodes = require "treewalker.nodes"

local M = {}

---@return nil
local function move_out(select)
  vim.cmd("normal! ^") -- TODO can somehow use nodes.get_at_row for this instead of this junk?
  local node = nodes.get_current()
  local target, row = targets.out(node)
  if not (target and row) then
    -- highlight the node anyways, for when normal! ^ does something
    operations.jump(node, nodes.get_srow(node))
    return
  end
  vim.cmd("normal! m'") -- Add originating node to jump list
  operations.jump(target, row, select)
  vim.cmd("normal! m'") -- Add destination node to jump list
end

---@return nil
local function move_in(select)
  local target, row = targets.inn()
  if not target or not row then return end
  vim.cmd("normal! m'")
  operations.jump(target, row, select)
  vim.cmd("normal! m'")
end

---@return nil
local function move_up(select)
  local node = nodes.get_current()
  local target, row = targets.up()
  if not target or not row then return end

  -- No neighbor jumplist additions in up
  local is_neighbor = nodes.have_neighbor_srow(node, target)
  if not is_neighbor then
    vim.cmd("normal! m'")
  end

  operations.jump(target, row, select)
end

---@return nil
local function move_down(select)
  local node = nodes.get_current()
  local target, row = targets.down()
  if not target or not row then return end

  -- down needs neighbor before and after jump
  local is_neighbor = nodes.have_neighbor_srow(node, target)
  if not is_neighbor then
    vim.cmd("normal! m'")
  end

  operations.jump(target, row, select)

  if not is_neighbor then
    vim.cmd("normal! m'")
  end
end

function M.move_out()
  move_out(false)
end

function M.move_in()
  move_in(false)
end

function M.move_up()
  move_up(false)
end

function M.move_down()
  move_down(false)
end

function M.select_out()
  move_out(true)
end

function M.select_in()
  move_in(true)
end

function M.select_up()
  move_up(true)
end

function M.select_down()
  move_down(true)
end

return M

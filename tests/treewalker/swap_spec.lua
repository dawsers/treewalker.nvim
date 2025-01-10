local load_fixture = require "tests.load_fixture"
local assert = require "luassert"
local tw = require 'treewalker'
local lines = require 'treewalker.lines'
local helpers = require 'tests.treewalker.helpers'

describe("Swapping in a regular lua file:", function()
  before_each(function()
    load_fixture("/lua.lua")
  end)

  it("swap down bails early if user is on empty top level line", function()
    local lines_before = lines.get_lines(0, -1)
    vim.fn.cursor(2, 1) -- empty line
    tw.swap_down()
    local lines_after = lines.get_lines(0, -1)
    helpers.assert_cursor_at(2, 1) -- unchanged
    assert.same(lines_after, lines_before)
  end)

  it("swap up bails early if user is on empty top level line", function()
    local lines_before = lines.get_lines(0, -1)
    vim.fn.cursor(2, 1) -- empty line
    tw.swap_up()
    local lines_after = lines.get_lines(0, -1)
    helpers.assert_cursor_at(2, 1) -- unchanged
    assert.same(lines_after, lines_before)
  end)

  it("swap down bails early if user is on empty line in function", function()
    local lines_before = lines.get_lines(0, -1)
    vim.fn.cursor(51, 1)
    tw.swap_down()
    local lines_after = lines.get_lines(0, -1)
    helpers.assert_cursor_at(51, 1) -- unchanged
    assert.same(lines_after, lines_before)
  end)

  it("swap up bails early if user is on empty line in function", function()
    local lines_before = lines.get_lines(0, -1)
    vim.fn.cursor(51, 1) -- empty line
    tw.swap_up()
    local lines_after = lines.get_lines(0, -1)
    helpers.assert_cursor_at(51, 1) -- unchanged
    assert.same(lines_after, lines_before)
  end)

  it("swaps down one liners without comments", function()
    vim.fn.cursor(1, 1)
    tw.swap_down()
    assert.same({
      "local M = {}",
      "",
      "local util = require('treewalker.util')"
    }, lines.get_lines(1, 3))
    helpers.assert_cursor_at(3, 1)
  end)

  it("swaps up one liners without comments", function()
    vim.fn.cursor(3, 1)
    tw.swap_up()
    assert.same({
      "local M = {}",
      "",
      "local util = require('treewalker.util')",
    }, lines.get_lines(1, 3))
    helpers.assert_cursor_at(1, 1)
  end)

  it("swaps down when one has comments", function()
    vim.fn.cursor(21, 1)
    tw.swap_down()
    assert.same("local function is_descendant_jump_target(node)", lines.get_line(19))
    assert.same("---@param node TSNode", lines.get_line(23))
    helpers.assert_cursor_at(25, 1)
  end)

  it("swaps up when one has comments", function()
    vim.fn.cursor(21, 1)
    tw.swap_up()
    assert.same({
      "---@param node TSNode",
      "---@return boolean",
      "local function is_jump_target(node)",
    }, lines.get_lines(10, 12))
    helpers.assert_cursor_at(12, 1)
  end)

  it("swaps down when both have comments", function()
    vim.fn.cursor(38, 1)
    tw.swap_down()
    assert.same({
      "---Strictly sibling, no fancy business",
      "---@param node TSNode",
      "---@return TSNode | nil",
      "local function get_prev_sibling(node)"
    }, lines.get_lines(34, 37))
    assert.same({
      "---Do the nodes have the same starting point",
      "---@param node1 TSNode",
      "---@param node2 TSNode",
      "---@return boolean",
      "local function have_same_range(node1, node2)"
    }, lines.get_lines(49, 53))
    helpers.assert_cursor_at(53, 1)
  end)

  it("swaps up when both have comments", function()
    vim.fn.cursor(49, 1)
    tw.swap_up()
    assert.same({
      "---Strictly sibling, no fancy business",
      "---@param node TSNode",
      "---@return TSNode | nil",
      "local function get_prev_sibling(node)"
    }, lines.get_lines(34, 37))
    assert.same({
      "---Do the nodes have the same starting point",
      "---@param node1 TSNode",
      "---@param node2 TSNode",
      "---@return boolean",
      "local function have_same_range(node1, node2)"
    }, lines.get_lines(49, 53))
    helpers.assert_cursor_at(37, 1)
  end)

  it("swaps right same size parameters", function()
    assert.same("local function have_same_range(node1, node2)", lines.get_line(38))
    vim.fn.cursor(38, 32)
    tw.swap_right()
    assert.same("local function have_same_range(node2, node1)", lines.get_line(38))
    helpers.assert_cursor_at(38, 39)
  end)

  it("swaps left same size parameters", function()
    assert.same("local function have_same_range(node1, node2)", lines.get_line(38))
    vim.fn.cursor(38, 39)
    tw.swap_left()
    assert.same("local function have_same_range(node2, node1)", lines.get_line(38))
    helpers.assert_cursor_at(38, 32)
  end)

  it("swaps right diff size parameters", function()
    assert.same("  return util.contains(TARGET_DESCENDANT_TYPES, node:type())", lines.get_line(31))
    vim.fn.cursor(31, 24)
    tw.swap_right()
    assert.same("  return util.contains(node:type(), TARGET_DESCENDANT_TYPES)", lines.get_line(31))
    helpers.assert_cursor_at(31, 37, "TARGET_DESCENDANT_TYPES")
  end)

  it("swaps left diff size parameters", function()
    assert.same("  return util.contains(TARGET_DESCENDANT_TYPES, node:type())", lines.get_line(31))
    vim.fn.cursor(31, 49)
    tw.swap_left()
    assert.same("  return util.contains(node:type(), TARGET_DESCENDANT_TYPES)", lines.get_line(31))
    helpers.assert_cursor_at(31, 24, "node:type()")
  end)

  it("swaps right diff number of lines", function()
    assert.same("if true then", lines.get_line(185)
    )
    assert.same("return M", lines.get_line(193))
    vim.fn.cursor(185, 1)
    tw.swap_right()
    assert.same("return M", lines.get_line(185))
    assert.same("if true then", lines.get_line(187))
    helpers.assert_cursor_at(187, 1)
  end)

  it("swaps left diff number of lines", function()
    assert.same("if true then", lines.get_line(185))
    assert.same("return M", lines.get_line(193))
    vim.fn.cursor(193, 1)
    tw.swap_left()
    assert.same("return M", lines.get_line(185))
    assert.same("if true then", lines.get_line(187))
    helpers.assert_cursor_at(185, 1)
  end)

  it("swaps right from inside strings", function()
    vim.fn.cursor(190, 10) -- somewhere inside "hi"
    tw.swap_right()
    assert.same("  print('bye', 'hi')", lines.get_line(190))
    helpers.assert_cursor_at(190, 16, "hi") -- cursor stays put for feel
  end)

  it("swaps left from inside strings", function()
    vim.fn.cursor(190, 17) -- somewhere inside "bye"
    tw.swap_left()
    assert.same("  print('bye', 'hi')", lines.get_line(190))
    helpers.assert_cursor_at(190, 9, "block") -- cursor stays put for feel
  end)
end)

-- doesn't work at all in md, doesn't need to
describe("Swapping in a markdown file:", function()
  before_each(function()
    load_fixture("/markdown.md")
    vim.bo[0].filetype = "markdown"
  end)

  it("turns off for down in md files", function()
    vim.fn.cursor(1, 1)
    local lines_before = lines.get_lines(0, -1)
    tw.swap_down()
    local lines_after = lines.get_lines(0, -1)
    assert.same(lines_after, lines_before)
  end)

  it("turns off for up in md files", function()
    vim.fn.cursor(3, 1)
    local lines_before = lines.get_lines(0, -1)
    tw.swap_up()
    local lines_after = lines.get_lines(0, -1)
    assert.same(lines_after, lines_before)
  end)

  it("turns off for left in md files", function()
    vim.fn.cursor(52, 3) -- TODO
    local lines_before = lines.get_lines(0, -1)
    tw.swap_left()
    local lines_after = lines.get_lines(0, -1)
    assert.same(lines_after, lines_before)
  end)

  it("turns off for right in md files", function()
    vim.fn.cursor(52, 3) -- TODO
    local lines_before = lines.get_lines(0, -1)
    tw.swap_right()
    local lines_after = lines.get_lines(0, -1)
    assert.same(lines_after, lines_before)
  end)

  it("follows lateral swaps across rows (like in these it args)", function()
    print("TODO")
  end)
end)

describe("Swapping in a c file:", function()
  before_each(function()
    load_fixture("/c.c")
  end)

  it("swaps right, when cursor is inside a string, the whole string", function()
    vim.fn.cursor(14, 17) -- the o in one
    assert.same('        printf("one\\n", "two\\n");', lines.get_line(14))
    tw.swap_right()
    assert.same('        printf("two\\n", "one\\n");', lines.get_line(14))
  end)

  it("swaps left, when cursor is inside a string, the whole string", function()
    vim.fn.cursor(17, 28) -- the t in two
    assert.same('        printf("one\\n", "\\ntwo\\n");', lines.get_line(17))
    tw.swap_left()
    assert.same('        printf("\\ntwo\\n", "one\\n");', lines.get_line(17))
  end)
end)

describe("Swapping in a rust file:", function()
  before_each(function()
    load_fixture("/rust.rs")
  end)

  it("Swaps enum values right", function()
    vim.fn.cursor(49, 14)
    assert.same('enum Color { Red, Green, Blue }', lines.get_line(49))
    tw.swap_right()
    assert.same('enum Color { Green, Red, Blue }', lines.get_line(49))
    helpers.assert_cursor_at(49, 21, "Red")
  end)

  it("Swaps enum values left", function()
    vim.fn.cursor(49, 19)
    assert.same('enum Color { Red, Green, Blue }', lines.get_line(49))
    tw.swap_left()
    assert.same('enum Color { Green, Red, Blue }', lines.get_line(49))
    helpers.assert_cursor_at(49, 14, "Red")
  end)

  -- The below issue is also happening in TSTextObjectSwapNext/Prev @parameter.inner
  -- In rust, node:parent() is taking us to a node that is way higher up than what
  -- appears to be the parent (via via.treesitter.inspect_tree())
  pending("Swaps right from a string to a fn call", function()
    vim.fn.cursor(46, 18) -- inside shape
    assert.same('    println!("shape_area", calculate_area(shape));', lines.get_line(46))
    tw.swap_right()
    assert.same('    println!(calculate_area(shape), "shape_area");', lines.get_line(46))
  end)

  pending("Swaps laterally from a string to a fn call", function()
    vim.fn.cursor(46, 32) -- inside calculate
    assert.same('    println!("shape_area", calculate_area(shape));', lines.get_line(46))
    tw.swap_left()
    assert.same('    println!(calculate_area(shape), "shape_area");', lines.get_line(46))
  end)

end)


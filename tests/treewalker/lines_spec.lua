local lines = require("treewalker.lines")
local assert = require("luassert")
local load_fixture = require("tests.load_fixture")

describe("lines", function()
  describe(".get_line", function()
    it("gets the line", function()
      load_fixture("lua.lua")
      local line = lines.get_line(3)
      assert.equals("local M = {}", line)
    end)
  end)

  describe(".get_lines", function()
    it("gets the lines", function()
      load_fixture("lua.lua")
      local line = lines.get_lines(3, 4)
      assert.same({ "local M = {}", "" }, line)
    end)
  end)

  describe(".set_line", function()
    it("sets the line", function()
      load_fixture("lua.lua")
      lines.set_line(3, "whattup")
      assert.equal("whattup", lines.get_line(3))
    end)
  end)

  describe(".set_lines", function()
    it("sets multiple lines", function()
      load_fixture("lua.lua")
      lines.set_lines(3, { "whattup", "wooo" })
      assert.same({ "whattup", "wooo" }, lines.get_lines(3, 4))
    end)

    it("sets one line", function()
      load_fixture("lua.lua")
      lines.set_lines(3, { "whattup" })
      assert.same({ "whattup" }, lines.get_lines(3, 3))
    end)

    it("replaces the line entirely", function()
      load_fixture("lua.lua")
      lines.set_lines(3, { "whattup" })
      assert.same({ "", "whattup", "" }, lines.get_lines(2, 4))
    end)
  end)

  describe(".insert_lines", function()
    it("inserts lines without deleting any", function()
      load_fixture("lua.lua")
      lines.insert_lines(1, {"hiya"})
      assert.same({ "local util = require('treewalker.util')", "hiya", "", "local M = {}" }, lines.get_lines(1, 4))
    end)

    it("deletes multiple lines", function()
      load_fixture("lua.lua")
      lines.delete_lines(1, 3)
      assert.same({ "", "local NON_TARGET_NODE_MATCHERS = {" }, lines.get_lines(1, 2))
    end)
  end)

  describe(".delete_lines", function()
    it("deletes single lines", function()
      load_fixture("lua.lua")
      lines.delete_lines(1, 1)
      assert.same({ "", "local M = {}" }, lines.get_lines(1, 2))
    end)

    it("deletes multiple lines", function()
      load_fixture("lua.lua")
      lines.delete_lines(1, 3)
      assert.same({ "", "local NON_TARGET_NODE_MATCHERS = {" }, lines.get_lines(1, 2))
    end)
  end)

  describe(".get_indent", function()
    it("gets the indent", function()
      load_fixture("lua.lua")
      local indent = lines.get_start_col("  local line = lines.get_indent()")
      assert.equals(3, indent)
    end)
  end)
end)

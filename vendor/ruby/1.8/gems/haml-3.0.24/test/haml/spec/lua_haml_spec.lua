require 'luarocks.require'
require 'json'
require 'telescope'
require 'haml'

local function get_tests(filename)
  local self = debug.getinfo(1).short_src
  if self:match("/") then return "./" .. self:gsub("[^/]*%.lua$", "/" .. filename)
  elseif self:match("\\") then return self:gsub("[^\\]*%.lua$", "\\" .. filename)
  else return filename
  end
end

local fh = assert(io.open(get_tests("tests.json")))
local input = fh:read '*a'
fh:close()

local contexts = json.decode(input)

describe("LuaHaml", function()
   for context, expectations in pairs(contexts) do
     describe("When handling " .. context, function()
      for name, exp in pairs(expectations) do
        it(string.format("should correctly render %s", name), function()
            assert_equal(haml.render(exp.haml, exp.config or {}, exp.locals or {}), exp.html)
        end)
      end
     end)
   end
end)

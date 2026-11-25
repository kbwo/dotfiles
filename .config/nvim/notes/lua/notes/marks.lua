-- The page marks: lines alone on their line that say something about the whole
-- page. "date:2026-11-05" is the day the page is to be taken up from; from that
-- day the list shows it after the pinned pages, until the date is taken off or
-- the page is closed. "closed:" (or "closed(2026-10-30 12:00:00):", as it is
-- written here) says the page is done with; its card is greyed out.
-- A port of stderr-blog's src/lib/cosense/page-marks.mjs, the authority.

local M = {}

local function is_day(day)
  local y, m, d = day:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
  if not y then
    return false
  end
  local t = os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12 })
  return os.date("%Y-%m-%d", t) == day
end

--- A line's date ("YYYY-MM-DD"), or nil when it is not a date line.
function M.date_of(line)
  local day = line:match("^%s*date:(%d%d%d%d%-%d%d%-%d%d)%s*$")
  return day and is_day(day) and day or nil
end

--- Whether a line is a closed mark.
function M.is_closed(line)
  return line:match("^%s*closed:%s*$") ~= nil or line:match("^%s*closed%([^()]*%):%s*$") ~= nil
end

function M.is_mark(line)
  return M.date_of(line) ~= nil or M.is_closed(line)
end

--- What a page's lines (title first) say of it: `date` ("YYYY-MM-DD" or nil) and `closed`.
function M.of(lines)
  local date, closed = nil, false
  for i = 2, #lines do
    date = date or M.date_of(lines[i])
    closed = closed or M.is_closed(lines[i])
  end
  return { date = date, closed = closed }
end

-- `lines` with the first line `is_mark` finds made `line`, or, without one, `line`
-- put in as the second line; that line taken out when `line` is nil.
local function with_mark_line(lines, is_mark, line)
  local out = vim.list_slice(lines)
  for i = 2, #out do
    if is_mark(out[i]) then
      if line then
        out[i] = out[i]:match("^%s*") .. line
      else
        table.remove(out, i)
      end
      return out
    end
  end
  if line then
    table.insert(out, 2, line)
  end
  return out
end

--- `lines` saying `day` instead, or without a date when `day` is nil.
function M.with_date(lines, day)
  return with_mark_line(lines, M.date_of, day and ("date:" .. day))
end

--- `lines` closed now, or opened again when `closed` is false.
function M.with_closed(lines, closed)
  return with_mark_line(lines, M.is_closed, closed and ("closed(" .. os.date("%Y-%m-%d %H:%M:%S") .. "):") or nil)
end

--- How far `day` is from `today`: "今日", "3日前", "あと3日".
function M.relative_day(day, today)
  local function t(d)
    local y, m, dd = d:match("^(%d+)%-(%d+)%-(%d+)$")
    return os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(dd), hour = 12 })
  end
  local days = math.floor((t(day) - t(today)) / 86400 + 0.5)
  return days == 0 and "今日" or days < 0 and (-days .. "日前") or ("あと" .. days .. "日")
end

return M

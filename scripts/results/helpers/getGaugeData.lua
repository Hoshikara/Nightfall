local GaugeProperties = require("common/constants/GaugeProperties")
local JsonTable = require("common/JsonTable")
local getGaugeValue = require("results/helpers/getGaugeValue")

---@param data result
---@param hardFail boolean
---@return integer|nil
local function getSwapIndex(data, hardFail)
	if (data.badge == 0) or hardFail then
		return
	end

	local index = getSetting("_gaugeSwapIndex", -1)

	if index == -1 then
		return
	end

	return index
end

---@param data result
---@param hardFail boolean
---@return number[]
local function getGaugeSamples(data, hardFail)
	if (data.badge == 0) or hardFail then
		return data.gaugeSamples
	end

	local samples = (JsonTable.new("samples")):get()

	if #samples == 0 then
		return data.gaugeSamples
	end

	return samples
end

---@param data result
---@param hardFail boolean
---@return ResultsGauge
local function getGaugeData(data, hardFail)
	local type = data.gauge_type or 0
	local gauge = GaugeProperties[type]

	if gauge.hasLevels then
		gauge.name = gauge.name .. (" [ %.1f ]"):format((data.gauge_option or 0) * 0.5)
	end

	if (type ~= 0) and (getSetting("_arsEnabled", 0) == 1) then
		gauge.name = gauge.name .. " + ARS"
	end

	gauge.currentValue = makeLabel("Number", "0", 18)
	gauge.endingValue = data.gauge
	gauge.labeledValue = getGaugeValue(data)
	gauge.label = makeLabel("SemiBold", gauge.name, 20)
	gauge.samples = getGaugeSamples(data, hardFail)
	gauge.swapIndex = getSwapIndex(data, hardFail)
	gauge.unlabeledValue = getGaugeValue(data, true)

	---@diagnostic disable-next-line
	return gauge
end

return getGaugeData

---@class ResultsGauge: GaugeProperties
---@field currentValue Label
---@field endingValue number
---@field label Label
---@field labeledValue Label
---@field level Label
---@field samples number[]
---@field swapIndex? integer
---@field unlabeledValue Label

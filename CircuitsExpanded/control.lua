
--Take a signal (set in the first block) and turn it into it's corresponding signal (set in the second block).
--code is from UsefulCombinators and is a temporary reminder of what to do.
classes["transformer-combinator"] = {
  on_click = function(player, object)
    local gui = player.gui.center
    if gui["uc"]["converter-combinator"]["from"].elem_value and gui["uc"]["converter-combinator"]["from"].elem_value.name then
      object.meta.params[1] = {signal = gui["uc"]["converter-combinator"]["from"].elem_value}
    else
      object.meta.params[1] = {type = "virtual"}
    end
    if gui["uc"]["converter-combinator"]["to"].elem_value and gui["uc"]["converter-combinator"]["to"].elem_value.name then
      object.meta.params[2] = {signal = gui["uc"]["converter-combinator"]["to"].elem_value}
    else
      object.meta.params[2] = {type = "virtual"}
    end
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local params = object.meta.params
      local gui = player.gui.center
      local uc = gui.add{type = "frame", name = "uc", caption = "Converter Combinator"}
      local layout = uc.add{type = "table", name = "converter-combinator", colspan = 4}
      layout.add{type = "label", caption = "From: "}
      if params[1].signal and params[1].signal.name then
        layout.add{type = "choose-elem-button", name = "from", elem_type = "signal", signal = params[1].signal}
      else
        layout.add{type = "choose-elem-button", name = "from", elem_type = "signal"}
      end
      layout.add{type = "label", caption = "To: "}
      if params[2].signal and params[2].signal.name then
        layout.add{type = "choose-elem-button", name = "to", elem_type = "signal", signal = params[2].signal}
      else
        layout.add{type = "choose-elem-button", name = "to", elem_type = "signal"}
      end
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
    end
  end,
  on_place = function(entity)
    return {
      meta = {
        entity = entity,
        params = {
          {signal = {type = "virtual"}},
          {signal = {type = "virtual"}}
        }
      }
    }
  end,
  on_destroy = function() end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      local params = object.meta.params
      if params[2].signal then
        if control.enabled then
          local slots = {}
          if params[2].signal.name then
            table.insert(slots, {signal = params[2].signal, count = get_count(control, params[1].signal), index = 1})
          end
          control.parameters = {
            parameters = slots
          }
        end
      else
        control.parameters = {
          parameters = {}
        }
      end
    end
  end
}



function get_count(control, signal)
  if not signal then return 0 end
  local red = control.get_circuit_network(defines.wire_type.red)
  local green = control.get_circuit_network(defines.wire_type.green)
  local val = 0
  if red then
    val = red.get_signal(signal) or 0
  end
  if green then 
    val = val + (green.get_signal(signal) or 0)
  end
  return val
end

function get_signals(control)
  local red = control.get_circuit_network(defines.wire_type.red)
  local green = control.get_circuit_network(defines.wire_type.green)
  local network = {}
  if red and red.signals then
    for _,v in pairs(red.signals) do
      if v.signal.name then
        network[v.signal.name] = v
      end
    end
  end
  if green and green.signals then
    for _,v in pairs(green.signals) do
      if v.signal.name then
        network[v.signal.name] = v
      end
    end
  end
  return network
end

defmodule Chromex do
  alias Chromex.DevtoolsProtocol.Debugger

  def new_page do
    Debugger.continue_to_location("", target_call_frames: "")
  end
end

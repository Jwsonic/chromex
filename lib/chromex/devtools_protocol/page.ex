defmodule Chromex.DevtoolsProtocol.Page do
  @moduledoc """
    Actions and events related to the inspected page belong to the page domain.
  """

  # Unique frame identifier.
  @type frame_id :: String.t()

  # Information about the Frame on the page.
  @type frame :: %{
          required(:id) => frame_id(),
          optional(:parentId) => String.t(),
          required(:loaderId) => Network.loader_id(),
          optional(:name) => String.t(),
          required(:url) => String.t(),
          optional(:urlFragment) => String.t(),
          required(:securityOrigin) => String.t(),
          required(:mimeType) => String.t(),
          optional(:unreachableUrl) => String.t()
        }

  # Information about the Resource on the page.
  @type frame_resource :: %{
          required(:url) => String.t(),
          required(:type) => Network.resource_type(),
          required(:mimeType) => String.t(),
          optional(:lastModified) => Network.time_since_epoch(),
          optional(:contentSize) => integer() | float(),
          optional(:failed) => boolean(),
          optional(:canceled) => boolean()
        }

  # Information about the Frame hierarchy along with their cached resources.
  @type frame_resource_tree :: %{
          required(:frame) => frame(),
          optional(:childFrames) => [frame_resource_tree()],
          required(:resources) => [frame_resource()]
        }

  # Information about the Frame hierarchy.
  @type frame_tree :: %{required(:frame) => frame(), optional(:childFrames) => [frame_tree()]}

  # Unique script identifier.
  @type script_identifier :: String.t()

  # Transition type.
  @type transition_type :: String.t()

  # Navigation history entry.
  @type navigation_entry :: %{
          required(:id) => integer(),
          required(:url) => String.t(),
          required(:userTypedURL) => String.t(),
          required(:title) => String.t(),
          required(:transitionType) => transition_type()
        }

  # Screencast frame metadata.
  @type screencast_frame_metadata :: %{
          required(:offsetTop) => integer() | float(),
          required(:pageScaleFactor) => integer() | float(),
          required(:deviceWidth) => integer() | float(),
          required(:deviceHeight) => integer() | float(),
          required(:scrollOffsetX) => integer() | float(),
          required(:scrollOffsetY) => integer() | float(),
          optional(:timestamp) => Network.time_since_epoch()
        }

  # Javascript dialog type.
  @type dialog_type :: String.t()

  # Error while paring app manifest.
  @type app_manifest_error :: %{
          required(:message) => String.t(),
          required(:critical) => integer(),
          required(:line) => integer(),
          required(:column) => integer()
        }

  # Parsed app manifest properties.
  @type app_manifest_parsed_properties :: %{required(:scope) => String.t()}

  # Layout viewport position and dimensions.
  @type layout_viewport :: %{
          required(:pageX) => integer(),
          required(:pageY) => integer(),
          required(:clientWidth) => integer(),
          required(:clientHeight) => integer()
        }

  # Visual viewport position, dimensions, and scale.
  @type visual_viewport :: %{
          required(:offsetX) => integer() | float(),
          required(:offsetY) => integer() | float(),
          required(:pageX) => integer() | float(),
          required(:pageY) => integer() | float(),
          required(:clientWidth) => integer() | float(),
          required(:clientHeight) => integer() | float(),
          required(:scale) => integer() | float(),
          optional(:zoom) => integer() | float()
        }

  # Viewport for capturing screenshot.
  @type viewport :: %{
          required(:x) => integer() | float(),
          required(:y) => integer() | float(),
          required(:width) => integer() | float(),
          required(:height) => integer() | float(),
          required(:scale) => integer() | float()
        }

  # Generic font families collection.
  @type font_families :: %{
          optional(:standard) => String.t(),
          optional(:fixed) => String.t(),
          optional(:serif) => String.t(),
          optional(:sansSerif) => String.t(),
          optional(:cursive) => String.t(),
          optional(:fantasy) => String.t(),
          optional(:pictograph) => String.t()
        }

  # Default font sizes.
  @type font_sizes :: %{optional(:standard) => integer(), optional(:fixed) => integer()}

  @type client_navigation_reason :: String.t()

  @type client_navigation_disposition :: String.t()

  @type installability_error_argument :: %{
          required(:name) => String.t(),
          required(:value) => String.t()
        }

  # The installability error
  @type installability_error :: %{
          required(:errorId) => String.t(),
          required(:errorArguments) => [installability_error_argument()]
        }

  # The referring-policy used for the navigation.
  @type referrer_policy :: String.t()

  @doc """
    Evaluates given script in every frame upon creation (before loading frame's scripts).
  """
  @spec add_script_to_evaluate_on_new_document(source :: String.t(),
          world_name: String.t(),
          async: boolean()
        ) :: %{}
  def add_script_to_evaluate_on_new_document(source, opts \\ []) do
    msg = %{
      "source" => source,
      "method" => "Page.addScriptToEvaluateOnNewDocument"
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:world_name], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Brings page to front (activates tab).
  """
  @spec bring_to_front(async: boolean()) :: %{}
  def bring_to_front(opts \\ []) do
    msg = %{
      "method" => "Page.bringToFront"
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Capture page screenshot.
  """
  @spec capture_screenshot(
          format: String.t(),
          quality: integer(),
          from_surface: boolean(),
          async: boolean()
        ) :: %{}
  def capture_screenshot(opts \\ []) do
    msg = %{
      "method" => "Page.captureScreenshot"
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:format, :quality, :from_surface], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Creates an isolated world for the given frame.
  """
  @spec create_isolated_world(frameId :: frame_id(),
          world_name: String.t(),
          grant_univeral_access: boolean(),
          async: boolean()
        ) :: %{}
  def create_isolated_world(frame_id, opts \\ []) do
    msg = %{
      "frameId" => frame_id,
      "method" => "Page.createIsolatedWorld"
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:world_name, :grant_univeral_access], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Disables page domain notifications.
  """
  @spec disable(async: boolean()) :: %{}
  def disable(opts \\ []) do
    msg = %{
      "method" => "Page.disable"
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Enables page domain notifications.
  """
  @spec enable(async: boolean()) :: %{}
  def enable(opts \\ []) do
    msg = %{
      "method" => "Page.enable"
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    
  """
  @spec get_app_manifest(async: boolean()) :: %{}
  def get_app_manifest(opts \\ []) do
    msg = %{
      "method" => "Page.getAppManifest"
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Returns present frame tree structure.
  """
  @spec get_frame_tree(async: boolean()) :: %{}
  def get_frame_tree(opts \\ []) do
    msg = %{
      "method" => "Page.getFrameTree"
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Returns metrics relating to the layouting of the page, such as viewport bounds/scale.
  """
  @spec get_layout_metrics(async: boolean()) :: %{}
  def get_layout_metrics(opts \\ []) do
    msg = %{
      "method" => "Page.getLayoutMetrics"
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Returns navigation history for the current page.
  """
  @spec get_navigation_history(async: boolean()) :: %{}
  def get_navigation_history(opts \\ []) do
    msg = %{
      "method" => "Page.getNavigationHistory"
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Accepts or dismisses a JavaScript initiated dialog (alert, confirm, prompt, or onbeforeunload).
  """
  @spec handle_java_script_dialog(accept :: boolean(), prompt_text: String.t(), async: boolean()) ::
          %{}
  def handle_java_script_dialog(accept, opts \\ []) do
    msg = %{
      "accept" => accept,
      "method" => "Page.handleJavaScriptDialog"
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:prompt_text], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Navigates current page to the given URL.
  """
  @spec navigate(url :: String.t(), referrer: String.t(), async: boolean()) :: %{}
  def navigate(url, opts \\ []) do
    msg = %{
      "url" => url,
      "method" => "Page.navigate"
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:referrer], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Navigates current page to the given history entry.
  """
  @spec navigate_to_history_entry(entryId :: integer(), async: boolean()) :: %{}
  def navigate_to_history_entry(entry_id, opts \\ []) do
    msg = %{
      "entryId" => entry_id,
      "method" => "Page.navigateToHistoryEntry"
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Print page as PDF.
  """
  @spec print_to_pdf(
          landscape: boolean(),
          display_header_footer: boolean(),
          print_background: boolean(),
          scale: integer() | float(),
          paper_width: integer() | float(),
          paper_height: integer() | float(),
          margin_top: integer() | float(),
          margin_bottom: integer() | float(),
          margin_left: integer() | float(),
          margin_right: integer() | float(),
          page_ranges: String.t(),
          ignore_invalid_page_ranges: boolean(),
          header_template: String.t(),
          footer_template: String.t(),
          prefer_css_page_size: boolean(),
          transfer_mode: String.t(),
          async: boolean()
        ) :: %{}
  def print_to_pdf(opts \\ []) do
    msg = %{
      "method" => "Page.printToPDF"
    }

    async = Keyword.get(opts, :async, false)

    params =
      reduce_opts(
        [
          :landscape,
          :display_header_footer,
          :print_background,
          :scale,
          :paper_width,
          :paper_height,
          :margin_top,
          :margin_bottom,
          :margin_left,
          :margin_right,
          :page_ranges,
          :ignore_invalid_page_ranges,
          :header_template,
          :footer_template,
          :prefer_css_page_size,
          :transfer_mode
        ],
        opts
      )

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Reloads given page optionally ignoring the cache.
  """
  @spec reload(ignore_cache: boolean(), script_to_evaluate_on_load: String.t(), async: boolean()) ::
          %{}
  def reload(opts \\ []) do
    msg = %{
      "method" => "Page.reload"
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:ignore_cache, :script_to_evaluate_on_load], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Removes given script from the list.
  """
  @spec remove_script_to_evaluate_on_new_document(identifier :: script_identifier(),
          async: boolean()
        ) :: %{}
  def remove_script_to_evaluate_on_new_document(identifier, opts \\ []) do
    msg = %{
      "identifier" => identifier,
      "method" => "Page.removeScriptToEvaluateOnNewDocument"
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Resets navigation history for the current page.
  """
  @spec reset_navigation_history(async: boolean()) :: %{}
  def reset_navigation_history(opts \\ []) do
    msg = %{
      "method" => "Page.resetNavigationHistory"
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Sets given markup as the document's HTML.
  """
  @spec set_document_content(frameId :: frame_id(), html :: String.t(), async: boolean()) :: %{}
  def set_document_content(frame_id, html, opts \\ []) do
    msg = %{
      "frameId" => frame_id,
      "html" => html,
      "method" => "Page.setDocumentContent"
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Force the page stop all navigations and pending resource fetches.
  """
  @spec stop_loading(async: boolean()) :: %{}
  def stop_loading(opts \\ []) do
    msg = %{
      "method" => "Page.stopLoading"
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  defp reduce_opts(keys, opts) do
    keys
    |> Enum.map(fn key -> {key, Keyword.get(opts, key, :missing)} end)
    |> Enum.reduce(%{}, fn
      {_key, :missing}, acc -> acc
      {key, value}, acc -> Map.put(acc, key, value)
    end)
  end
end

defmodule Mix.Tasks.Guardian.Gen.EmailLogin do
  use Mix.Task

  @shortdoc "Generate template for guardian email login"

  def run(args) do
    switches = []

    {_opts, parsed, _} = OptionParser.parse(args, switches: switches)
    [singular, _plural | _attrs] = validate_args!(parsed)

    binding   = Mix.Phoenix.inflect(singular)
    path      = binding[:path]

    files = [
      {:eex, "guardian_serializer.ex", "lib/#{path}/guardian_serializer.ex"},
      {:eex, "migration.exs", "priv/repo/migrations/#{timestamp()}_create_user.exs"}
    ]

    Mix.Phoenix.copy_from paths(), "priv/templates/guardian.gen.email_login", "", binding, files

    Mix.shell.info """
    Remember to update your repository by running migrations:

      $ mix ecto.migrate
    """
  end

  defp validate_args!([_, plural | _] = args) do
    cond do
      String.contains?(plural, ":") ->
        raise_with_help
      plural != Phoenix.Naming.underscore(plural) ->
        Mix.raise "expected the second argument, #{inspect plural}, to be all lowercase using snake_case convention"
      true ->
        args
    end
  end
  defp validate_args!(_) do
    raise_with_help
  end

  defp raise_with_help do
    Mix.raise """
    mix guardian.gen.email_login expects both singular and plural names
    of the application:

        mix guardian.gen.email_login ApplicationName application_name
    """
  end

  defp paths() do
    [".", :gen_guardian]
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: << ?0, ?0 + i >>
  defp pad(i), do: to_string(i)
end

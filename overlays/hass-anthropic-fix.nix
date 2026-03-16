final: prev: {
  home-assistant = prev.home-assistant.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (final.writeText "ha-anthropic-top-level-schema-sanitize.patch" ''
        diff --git a/homeassistant/components/anthropic/entity.py b/homeassistant/components/anthropic/entity.py
        index 3cce4eb8b87..35f2bc4b0ec 100644
        --- a/homeassistant/components/anthropic/entity.py
        +++ b/homeassistant/components/anthropic/entity.py
        @@ -111,16 +111,34 @@
         # Max number of back and forth with the LLM to generate a response
         MAX_TOOL_ITERATIONS = 10


        +def _sanitize_tool_schema(input_schema: dict[str, Any]) -> dict[str, Any]:
        +    """Sanitize schema to comply with Anthropic's top-level restrictions.
        +
        +    Anthropic rejects tool schemas with top-level `oneOf`, `allOf`, or `anyOf`.
        +    We only remove these keys at the root level and keep nested combinators.
        +    Runtime voluptuous validation still enforces the argument constraints.
        +    """
        +
        +    for combinator in ("oneOf", "allOf", "anyOf"):
        +        input_schema.pop(combinator, None)
        +
        +    return input_schema
        +
        +
         def _format_tool(
             tool: llm.Tool, custom_serializer: Callable[[Any], Any] | None
         ) -> ToolParam:
             """Format tool specification."""
        +    input_schema = _sanitize_tool_schema(
        +        convert(tool.parameters, custom_serializer=custom_serializer)
        +    )
        +
             return ToolParam(
                 name=tool.name,
                 description=tool.description or "",
        -        input_schema=convert(tool.parameters, custom_serializer=custom_serializer),
        +        input_schema=input_schema,
             )


         @dataclass(slots=True)
      '')
    ];
  });
}

;; extends

(call_expression
  function: (identifier) @__name (#eq? @__name "Component")
  arguments: (arguments
    (object
      (pair
        key: (property_identifier) @__prop_name (#eq? @__prop_name "template")
        value: (template_string) @injection.content
        (#set! injection.language "angular")
        (#set! injection.combined)
      )
    )
  )
)


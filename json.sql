UPDATE my_table
SET json_column = JSON_TRANSFORM(
  json_column,
  SET '$[*]?(@.description =~ ".*cbpr\\+.*" && @.output == "cbprplus.02").output' = 'cbprplus.03'
)
WHERE JSON_EXISTS(
  json_column,
  '$[*]?(@.description =~ ".*cbpr\\+.*" && @.output == "cbprplus.02")'
);

SELECT id,
       JSON_TRANSFORM(
         json_column,
         SET '$[*]?(@.description =~ ".*ABC.*").output' = 'cbpr'
       ) AS modified_json
FROM my_table
WHERE JSON_EXISTS(json_column, '$[*]?(@.description =~ ".*ABC.*")');
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

DECLARE
  v_json      CLOB;
  v_new_json  CLOB;
  v_array     JSON_ARRAY_T;
  v_obj       JSON_OBJECT_T;
  i           INTEGER;
BEGIN
  FOR rec IN (
    SELECT id, json_column
    FROM my_table
    WHERE json_column IS NOT NULL
    FOR UPDATE
  ) LOOP
    BEGIN
      -- 尝试将 CLOB 解析为 JSON Array
      v_array := JSON_ARRAY_T.parse(rec.json_column);

      FOR i IN 0 .. v_array.get_size - 1 LOOP
        v_obj := TREAT(v_array.get(i) AS JSON_OBJECT_T);

        IF v_obj.has('description') AND v_obj.has('output') THEN
          IF v_obj.get_string('description') LIKE '%cbpr+%'
             AND v_obj.get_string('output') = 'cbprplus.02' THEN
             
             -- 修改 output 字段
             v_obj.put('output', 'cbprplus.03');
          END IF;
        END IF;
      END LOOP;

      -- 将更新后的 JSON Array 转为字符串
      v_new_json := v_array.to_string;

      -- 写回原表
      UPDATE my_table
      SET json_column = v_new_json
      WHERE id = rec.id;

    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('Error processing ID: ' || rec.id || ' - ' || SQLERRM);
    END;
  END LOOP;

  COMMIT;
END;
/

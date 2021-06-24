let
    #"Query1 (3)" = let
    f = (InputTable) => let
        Source = 
            Table.Schema(InputTable),
        SortRows = 
            Table.Sort(
                Source,
                {{"Position", Order.Ascending}}),
        RemoveColumns = 
            Table.SelectColumns(
                SortRows,
                {"Name", "TypeName"}),
        AddCustom = 
            Table.AddColumn(
                RemoveColumns, 
                "TypeNames", 
                each 
                Expression.Identifier([Name]) & " = " & [TypeName]),
        Output = 
            "[" & Text.Combine(AddCustom[TypeNames], ", ") & "]"
    in
        SortRows
in
    Table.NestedJoin(f(Vareposter), {"Name"}, f(#"Vareposter (new)"), {"Name"}, "Query1 (3)", JoinKind.FullOuter),
    #"Expanded Query1 (3)" = Table.ExpandTableColumn(#"Query1 (3)", "Query1 (3)", {"Name", "Position", "TypeName", "Kind", "IsNullable", "NumericPrecisionBase", "NumericPrecision", "NumericScale", "DateTimePrecision", "MaxLength", "IsVariableLength", "NativeTypeName", "NativeDefaultExpression", "NativeExpression", "Description", "IsWritable"}, {"Query1 (3).Name", "Query1 (3).Position", "Query1 (3).TypeName", "Query1 (3).Kind", "Query1 (3).IsNullable", "Query1 (3).NumericPrecisionBase", "Query1 (3).NumericPrecision", "Query1 (3).NumericScale", "Query1 (3).DateTimePrecision", "Query1 (3).MaxLength", "Query1 (3).IsVariableLength", "Query1 (3).NativeTypeName", "Query1 (3).NativeDefaultExpression", "Query1 (3).NativeExpression", "Query1 (3).Description", "Query1 (3).IsWritable"}),
    #"Removed Other Columns" = Table.SelectColumns(#"Expanded Query1 (3)",{"Name", "Query1 (3).Name"})
in
    #"Removed Other Columns"

// Reads tables in the active Power BI model, exposing non-folding m-queries.
// Also gives reveals transpiled SQL "Native Queries" for successfully folding queries.

let
    GetNativeQuery = (T as table) =>
    let
        FindQueryRecord = Value.ResourceExpression(T),
        SourceCode = FindQueryRecord[Arguments]{1}[Value]
    in
        try SourceCode otherwise "Unable to complete Query Folding step",

    #" " = "",

    #"#shared as Table" = Record.ToTable(#shared),
    #"Filtered Rows" = Table.SelectRows(
        #"#shared as Table",
        each (Type.Is(Value.Type([Value]), type table))
    ),
    #"Invoked Custom Function" = Table.AddColumn(
        #"Filtered Rows",
        "Native Query",
        each GetNativeQuery([Value])
    ),
    #"Renamed Columns" = Table.RenameColumns(
        #"Invoked Custom Function",
        {
            {"Name", "Table Name"}
        }
    ),
    #"Removed Columns" = Table.RemoveColumns(
        #"Renamed Columns",
        {"Value"}
    ),
    #"Sorted Rows" = Table.Sort(
        #"Removed Columns",
        {
            {"Table Name", Order.Ascending}
        }
    )
in
    #"Sorted Rows"

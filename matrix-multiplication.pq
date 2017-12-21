(MatrixA as table, MatrixB as table) =>
let
    // Test-data:
    //MatrixA = Table.FromColumns({{0, 2, 3}, {1, 4, 2}, {1, 3, 5}}, type table [x1 = Int64.Type, x2 = Int64.Type, Y = Int64.Type]),
    //MatrixB =Table.FromColumns({{0.2, 0.4, 0.9}}, type table [Theta = number]),

    // Row and culumn indecies as numerical lists
    #"Row Indices" = List.Numbers(0, Table.RowCount(MatrixA)),
    #"Column Indices" = List.Numbers(0, Table.ColumnCount(MatrixB)),

    // Init resulting table by creating one column with number of rows
    #"Rows Indices To Table" = Table.FromList(
        #"Row Indices",
        Splitter.SplitByNothing(),
        null,
        null,
        ExtraValues.Error
    ),
    #"Renamed Row Column" = Table.RenameColumns(
        #"Rows Indices To Table",
        {{"Column1", "Row"}}
    ),

    // Add all column indeces as list in each row
    #"Add Column Indices" = Table.AddColumn(
        #"Renamed Row Column", 
        "Column Indices",
        each #"Column Indices"
    ),

    // Expand indices to separated columns in table
    #"Expanded Indices" = Table.ExpandListColumn(
        #"Add Column Indices",
        "Column Indices"
    ),

    // Add data from each row in Matrix A as lists in single column
    #"Added Row Data" = Table.AddColumn(
        #"Expanded Indices",
        "Row Data",
        each Record.FieldValues(MatrixA{[Row]})
    ),

    // Add data from each column in Matrix B as lists in single column
    MatrixBColumns = Table.ToColumns(MatrixB),
    #"Added Column Data" = Table.AddColumn(
        #"Added Row Data",
        "Column Data",
        each MatrixBColumns{[Column Indices]}
    ),
    
    // Generate a list by looping over two lists and multiplying the values.
    // Sum the resulting list to get a number value.
    fnMatrixProduct = (list1, list2) =>
        List.Sum(
            List.Generate(
                () => [A = list1, B = list2, Index = 0], // Init
                each [Index] < List.Count([A]), // While True
                each [A = [A], B = [B], Index = [Index] + 1], // Do this
                each [A]{[Index]} * [B]{[Index]} // Return this for every step (including 0)
            )
        ),
    
    // Add column containing Matrix product for rows
    #"Added Product" = Table.AddColumn(
        #"Added Column Data",
        "Product",
        each fnMatrixProduct([Row Data], [Column Data])
    ),

    // Clean up
    #"Removed Data Columns" = Table.RemoveColumns(
        #"Added Product",
        {"Row Data", "Column Data"}
    ),

    #"Retyped Column Indices" = Table.TransformColumnTypes(
        #"Removed Data Columns",
        {{"Column Indices", type text}}, 
        "en-US"
    ),

    #"Pivoted Column" = Table.Pivot(
        #"Retyped Column Indices",
        List.Distinct(#"Retyped Column Indices"[Column Indices]),
        "Column Indices",
        "Product"
    ),
    #"Removed Columns" = Table.RemoveColumns(#"Pivoted Column",{"Row"})
in
    #"Removed Columns"

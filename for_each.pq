let
    for_each = (list_for_iteration as list, action as function, state as any) as any =>
    let
        // We use recursion to loop over a list, applying a specified action to the passed state at each step.
        f = (self as function, index as number, list_for_iteration as list, action as function, state as any) =>
            let
                _index = index + 1,
                stop_iteration = _index >= List.Count(list_for_iteration),

                iter = list_for_iteration{index},
                new_state = action(state, iter)
            in
                if stop_iteration then new_state else self(self, _index, list_for_iteration, action, new_state)
    in
        f(f, 0, list_for_iteration, action, state),

    // Demo parameters:
    // List of items to iterate over
    list_of_stuff =
        //List.Generate(()=>0, each _ < 10, each _ + 1)
        {"One", "Two", "Three", "Four", "Five"},
    
    // Function to apply to each element in the list
    action = (state as text, iter as text) => state & " " & iter,

    // The initial state for the loop
    state = ""
in
    for_each(list_of_stuff, action, state)

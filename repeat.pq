let
    Repeat = (repetitions as number, action as function, state as any) as any =>
        let
            // We generate a list of numbers to iterate over as we perform a specified action with each pass.
            range = List.Generate(()=>0, each _ < repetitions, each _ + 1),
            f = (self as function, index as number, range as list, action as function, state) =>
                let
                    _index = index + 1,
                    stop_iteration = _index >= List.Count(range),
                    new_state = action(state)
                in
                    if stop_iteration then new_state else self(self, _index, range, action, new_state)
        in
            f(f, 0, range, action, state),
    // Demo parameters:
    // How many times to repete the action
    Repetitions = 10,

    // Which action to perform
    Action = (state) => Number.Power(state, 2),

    // The initial state of the process
    Initial_State = 2
in
    Repeat(Repetitions, Action, Initial_State)

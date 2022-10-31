# [Hooks](@id hooks)

Hooks enable you to dynamically choose to inject functionality into algorithms.
Some hooks are mandatory for certain algorithms, such as having a hook with the
[`SemioticOpt.IsStoppingCondition`](@ref) trait when using
[`SemioticOpt.GradientDescent`](@ref).
Others are purely there for you to use at your discretion.
In this section, we'll take you through [Traits](@ref), [Using Predefined Hooks](@ref)
and how to [Create Custom Hooks](@ref).

## Traits

Hooks have traits.
This is how our code knows when to execute which hook.
For example, the code will execute a hook that has the [`SemioticOpt.IsStoppingCondition`](@ref) trait
when evaluating whether it has finished optimising.
A full list of traits follows.

### StopTrait

This trait tells the code if it should execute a hook when checking stopping conditions.
By default, the code automatically gives all hooks the
[`SemioticOpt.IsNotStoppingCondition`](@ref) trait except in certain situations, which are
explicitly documented with the hooks in question.
We decide to stop code execution on an `OR` basis.
This means that if *any* hook with [`SemioticOpt.IsStoppingCondition`](@ref) returns `true`,
the code breaks out of the optimisation loop.
Hooks with this trait must implement [`SemioticOpt.stophook`](@ref).

```@docs
SemioticOpt.StopTrait
SemioticOpt.IsStoppingCondition
SemioticOpt.IsNotStoppingCondition
SemioticOpt.stophook
```

### PostIterationTrait

This trait tells the code if it should execute the hook after it calls
[`SemioticOpt.iteration`](@ref).
All hooks default to the [`SemioticOpt.DontRunAfterIteration`](@ref) trait unless otherwise
documented.
Hooks with this positive variant of this trait [`SemioticOpt.RunAfterIteration`](@ref) must
return `z`, the output of `iteration`.
Hooks with this trait must also implement [`SemioticOpt.postiterationhook`](@ref).

```@docs
SemioticOpt.PostIterationTrait
SemioticOpt.RunAfterIteration
SemioticOpt.DontRunAfterIteration
SemioticOpt.postiterationhook
```

## Using Predefined Hooks

Hooks always descend from the same abstract type.

```@docs
SemioticOpt.Hook
```

Generally speaking, pre-defined hooks won't exhibit any positive traits unless explicitly documented otherwise.
This serves two purposes.
Firstly, it prevents any unexpected behaviour when the code executes.
Secondly, it gives you more flexibility when choosing where you want a hook to be executed.

!!! warning
    This section is incomplete! We will fill this out more once we have more traits and hooks to work with.
    
!!! note
    We recommend you read the below [StopWhen](@ref) section as it explains details that we won't cover in the later sections since it'd be too repetitive.
    
### StopWhen

This hook has the [`SemioticOpt.IsStoppingCondition`](@ref) trait.
To use it, you would specify a function that returns a boolean value.
If said value is `true`, then the code breaks out of the optimisation loop.

Let's take an example from our tests to demonstrate how to specify this hook.
We'll also implement a dummy optimisation function that just implements a counter
for illustration purposes.

```julia
julia> using SemioticOpt
julia> struct FakeOptAlg <: SemioticOpt.OptAlgorithm end
juila> a = FakeOptAlg()
julia> function counter(h, a)
            i = 0
            while !shouldstop(h, a; Base.@locals()...)
                i += 1
            end
            return i
        end
julia> h = StopWhen((a; locals...) -> locals[:i] ≥ 5, Dict())  # Stop when i ≥ 5
julia> i = counter((h,), a)
5
```

One thing you may not have seen is `Base.@locals`.
This takes variables from the local scope (in this case, from the `counter` scope),
and tracks them as a dictionary of symbols.
Thus, since `i` is a local variable inside of `counter`, `:i` becomes a key in the
`Base.@locals` dictionary.
We pass this dictionary to the anonymouse function stored by `StopWhen`.
Then, we can use `locals[:i]` to get the value of `i` from the `counter` scope and
check it against some condition.
This is a powerful trick you may find yourself using a lot when dealing with hooks.

```@docs
SemioticOpt.StopWhen
```

## Create Custom Hooks

When you create a custom hook, you need to follow three steps.
The first is that you need to descend from [`SemioticOpt.Hook`](@ref).

```julia
julia> using SemioticOpt
julia> struct MyHook <: Hook end
```

The second is that you need to ensure that you specify which traits you want that hook to exhibit.
For example, let's say `MyHook` is a stopping condition.
You'd want to implement.

```julia
julia> StopTrait(::Type{MyHook}) = IsStoppingCondition()
```

Finally, if you need non-default behaviour for when the hook executes, you'll need to implement
whatever function(s) the code calls for that trait-type.
For `IsStoppingCondition`, that's `stophook`.
Say we want `MyHook` to immediately cause optimisation to finish.
We'd implement

```julia
julia> stophook(h::MyHook, a::SemioticOpt.OptAlgorithm; locals...) = true
```

That's it!
As long as your follow those three steps, you should be able to implement whatever hook you want!

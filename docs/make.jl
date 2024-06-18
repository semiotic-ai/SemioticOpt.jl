using SemioticOpt
using Documenter

DocMeta.setdocmeta!(SemioticOpt, :DocTestSetup, :(using SemioticOpt); recursive=true)

makedocs(;
    modules=[SemioticOpt],
    authors="Semiotic Labs",
    sitename="SemioticOpt.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://semiotic-ai.github.io/SemioticOpt.jl",
        edit_link="main",
        assets=String[]
    ),
    pages=[
        "Home" => "index.md",
        "Algorithms" => "algorithms.md",
        "Hooks" => "hooks.md",
        "API" => "api.md",
    ]
)

deploydocs(;
    repo="github.com/semiotic-ai/SemioticOpt.jl",
    devbranch="main",
    devurl="latest"
)

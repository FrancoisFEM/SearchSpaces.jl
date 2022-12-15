using Documenter, SearchSpaces

makedocs(
         format = Documenter.HTML(
                                  prettyurls = get(ENV, "CI", nothing) == "true",
                                  collapselevel = 2,
                                  # assets = ["assets/favicon.ico", "assets/extra_styles.css"],
                                 ),
         sitename="SearchSpaces.jl",
         authors = "Jesus-Adolfo Mejia-de-Dios",
         pages = [
                  "Index" => "index.md",
                  "Examples" =>  "examples.md",
                  "API References" => "api.md",
                 ]
        )


deploydocs(
           repo = "github.com/jmejia8/SearchSpaces.jl",
          )

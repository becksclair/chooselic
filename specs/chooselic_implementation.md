# Implementation of `chooselic`

Read @../README.md and @../repomix-vscode-choosealicense.xml which contains a full single-file dump of the `vscode-choosealicense` project.

Then implement a terminal app that takes command line arguments to specify the values of template replacement on the license files.

Example:

```
$ chooselic --license MIT --author Rebecca Clair --year 2025
```

When not specifying a license in the command line arguments, the program uses the [illwill](https://github.com/johnnovak/illwill) and [tui\_widget](https://github.com/jaar23/tui_widget) libraries to draw a list box with all the available licenses, and an input field preceding it where it fuzzy filters the license list.

If the user didn't specify the `author` or the `year` arguments either, the program, shows another panel with input boxes both `author` and `year`, capture those values to then pull the license template, inject those fields into it, and then save the file.

The program should save a copy of the original template it downloads into a cache folder `$HOME/.cache/chooselic/` and before downloading licenses it should first check if there's a cached file and use that instead of always hitting the API endpoint. The program should also cache the available licenses in a JSON file in `$HOME/.cache/chooselic/licenses.json` that should contain the names and download URLs, and any other metadata you may need.

## Testing

There should be >80% test coverage in the project. Covering >90% of cases where all the inputs are provided in the command line arguments.



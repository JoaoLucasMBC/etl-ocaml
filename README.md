# **ETL OCaml**

This project is an OCaml-based ETL application. Follow the instructions below to build, run, and test the project.

The complete report can be found in the `report.md` file.

## Setup

1. **Clone the Repository**

   Open your terminal and run:

   ```sh
   git clone <repo-url>
   cd etl-ocaml
   ```

2. **Open in Docker Container (Devcontainer)**

   If you use VSCode, click on **"Reopen in Container"** when prompted. This will load the project inside the pre-configured devcontainer.

3. **Set Up the OPAM Environment**

   Once inside the container, run:

   ```sh
   eval $(opam env)
   ```

## Building the Project

1. Change to the `etl` folder:

   ```sh
   cd etl
   ```

2. Build the project using Dune:

   ```sh
   dune build
   ```

3. If there is an error in the command above, there was probably a problem while installing the dependencies. You can install them directly by running:

   ```sh
   opam install --deps-only .
   ```

   or

   ```sh
   opam install -y dune utop ocaml-lsp-server odoc csv sqlite3 ptime cohttp-lwt-unix ounit2 lwt_ssl
   ```

## Running the Application

From the `etl` folder, run the application with:

```sh
dune exec etl
```

### Running with filters

You can run the application with filters for STATUS and/or ORIGIN, respecting the same format they appear in the original CSV files. For example:

```sh
dune exec -- etl --status "Complete" --origin "P"
```

The options for the filters are:
- `--status`: `"Complete"`, `"Pending"`, and `"Cancelled"`.  
- `--origin`: `"P"` and `"O"`.

Also, you can run the help command to see all available options:

```sh
dune exec etl -- --help
```

### File Locations

In this version of the project, it is not possible to customize the input and output file locations. The input files are located in the `data` folder, and the output file will be created in the same folder with the name `output.db`.

## Running Tests

To run the unit tests, execute:

```sh
dune runtest
```

This will run all tests defined in the `test` folder. The test results will be displayed in the terminal.

After that, if you try to run again, it will only run the tests that were modified since the last run.

## Generating Documentation

This project uses `odoc` for documentation. To generate the HTML documentation:

1. In the `etl` folder, run:

   ```sh
   dune build @doc
   ```

2. The documentation HTML files will be located in:

   ```
   _build/default/_doc/_html
   ```

   Open the `index.html` file in your browser, or serve it using your favorite static server.

## Database Requirement

For the application to work properly, you must create a SQLite database file called `output.db` in the `data` folder. 

It should be created automatically by the program, but if you want to create it manually, you can do so by running the following commands:

```sh
touch data/output.db
```
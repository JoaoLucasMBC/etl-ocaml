# etl-ocaml

This project is an OCaml-based ETL application. Follow the instructions below to build, run, and test the project.

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

## Running the Application

From the `etl` folder, run the application with:

```sh
dune exec etl
```

## Running Tests

To run the unit tests, execute:

```sh
dune runtest
```

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

For the application to work properly, you must create a SQLite database file called `output.db` in the `data` folder. Run the following commands:

```sh
mkdir -p data
touch data/output.db
```

Ensure that the `output.db` file exists before running the application.
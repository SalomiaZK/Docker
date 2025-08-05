from flask import Flask, request
import subprocess
import os

app = Flask(__name__)

OCAML_BINARY_PATH = "./marina/marina"  # Remarque : binaire dans le dossier marina

@app.route("/marina", methods=["GET"])
def execute_existing_ocaml_binary():
    search_query = request.args.get('laza')

    if search_query is None:
        return "Error: 'laza' parameter is required", 400

    # Compile le code OCaml avant tout
    try:
        make_proc = subprocess.run(
            ["make"],
            cwd="./marina",
            
            capture_output=True,
            text=True,
            timeout=10
        )
        if make_proc.returncode != 0:
            return f"Make failed (code {make_proc.returncode}):\n{make_proc.stderr}", 500
    except Exception as e:
        return f"Error running make: {str(e)}", 500

    # Vérifie le binaire compilé
    if not os.path.exists(OCAML_BINARY_PATH):
        return f"Error: OCaml binary not found at {OCAML_BINARY_PATH}", 500
    if not os.access(OCAML_BINARY_PATH, os.X_OK):
        return f"Error: OCaml binary at {OCAML_BINARY_PATH} is not executable. Please run 'chmod +x {OCAML_BINARY_PATH}'", 500

    # Exécute le binaire avec le paramètre
    try:
        run_proc = subprocess.run(
            [OCAML_BINARY_PATH, search_query],
            capture_output=True,
            text=True,
            timeout=3
        )
        if run_proc.returncode != 0:
            return f"Execution error (code {run_proc.returncode}): {run_proc.stderr}", 500

        return run_proc.stdout or "(no output)"
    except subprocess.TimeoutExpired:
        return "Execution timeout", 408
    except Exception as e:
        return f"Internal server error: {str(e)}", 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)

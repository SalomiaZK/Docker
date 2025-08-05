from flask import Flask, request
import subprocess
import os

app = Flask(__name__)

# --- CONFIGURATION ---
# Chemin vers le binaire OCaml exécutable
# S'Assure que ce chemin est correct et que le fichier a les permissions d'exécution (chmod +x)
OCAML_BINARY_PATH = "./marina"

@app.route("/marina", methods=["GET"])
def execute_existing_ocaml_binary():
    search_query = request.args.get('laza') 

    if not os.path.exists(OCAML_BINARY_PATH):
        return f"Error: OCaml binary not found at {OCAML_BINARY_PATH}", 500
    if not os.access(OCAML_BINARY_PATH, os.X_OK):
        return f"Error: OCaml binary at {OCAML_BINARY_PATH} is not executable. Please run 'chmod +x {OCAML_BINARY_PATH}'", 500

    try:
        
        run_proc = subprocess.run(
            [
                OCAML_BINARY_PATH,
                search_query
                ],
            capture_output=True,
            text=True,
            timeout=3,
            cwd="marina" 
        )
        
        
        

        if search_query is None:
            return "Error: 'query' parameter is required", 400
        # 'flask'
        # Si le binaire a retourné une erreur (code de sortie non nul)
        if run_proc.returncode != 0:
            return f"Execution error (code {run_proc.returncode}): {run_proc.stderr}", 500

        return run_proc.stdout or "(no output)"

    except subprocess.TimeoutExpired:
        return "Execution timeout", 408

    except Exception as e:
        return f"Internal server error: {str(e)}", 500

if __name__ == "__main__":
    # IMPORTANT: Écoute sur toutes les interfaces, port 8080
    app.run(host="0.0.0.0", port=8080)
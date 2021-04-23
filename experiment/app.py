from flask import Flask, request, render_template, redirect

# set the project root directory as the static folder, you can set others.
# app = Flask(__name__, static_folder="/static")
# app = Flask(__name__, template_folder="../templates", static_folder="../static")
app = Flask(__name__)
@app.route("/")
def home_page():
    # look inside `templates` and serve `index.html`
    return render_template('index.html')

@app.route("/save_data", methods=['POST'])
def save_data():
    # POST request
    if request.method == 'POST':
        print('POST REQUEST INCOMING')
        print(request.get_json())  # parse as JSON
        return 'OK', 200

if __name__ == '__main__':
    app.run(debug=True)

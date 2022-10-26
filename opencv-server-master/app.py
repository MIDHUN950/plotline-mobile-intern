import os
from flask import Flask, request
import base64
import cv2

# Flask constructor takes the name of
# current module (__name__) as argument.
app = Flask(__name__)


# The route() function of the Flask class is a decorator,
# which tells the application which URL should call
# the associated function.
@app.route('/')
# ‘/’ URL is bound with hello_world() function.
def hello_world():
    return 'Hello World!'

@app.route('/opencv', methods = ['POST','GET'])
def getresponse():
    if request.method == 'POST':
        f = request.files['file']
        print(request.query_string)
        print(request)
        print(request.args)
        id = request.args["id"]
        print(id)
        filenam = id+f.filename
        f.save(filenam)
        img = cv2.imread(filenam)  # Read image
        # Setting parameter values  
        t_lower = 50  # Lower Threshold
        t_upper = 150  # Upper threshold
        # Applying the Canny Edge filter
        edge = cv2.Canny(img, t_lower, t_upper)
        # cv2.imwrite(filename,edge)
        _, im_arr = cv2.imencode('.jpg', edge)  # im_arr: image in Numpy one-dim array format.
        im_bytes = im_arr.tobytes()
        im_b64 = base64.b64encode(im_bytes)
        os.remove(id+f.filename)
        return im_b64
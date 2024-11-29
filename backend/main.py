import PIL
import matplotlib
matplotlib.use('Agg')
from flask import Flask, request, send_file, abort, jsonify
import matplotlib.pyplot as plt
import mne
import os

os.environ['TF_ENABLE_ONEDNN_OPTS'] = '0'
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
from flask_cors import CORS
import tempfile
from io import BytesIO
import numpy as np
import base64
import tensorflow as tf
import keras
from mne.preprocessing import ICA


ica = ICA(n_components=15, random_state=97)

app = Flask(__name__)
CORS(app)
def process_edf(file):
    try:
        temp_file = tempfile.NamedTemporaryFile(suffix=".edf", dir='temp', delete=False)
        temp_file_path = temp_file.name

        with open(temp_file_path, 'wb') as x:
            x.write(file.read())

        # Reading raw edf data
        raw = mne.io.read_raw_edf(temp_file_path, eog=None, misc=None, stim_channel='auto', exclude=(), preload=True, verbose=0)

        # pick only eeg data
        raw.pick_types(eeg=True)

        # Apply a bandpass filter between 0.5 - 45 Hz
        raw.filter(0.5, 45)

        # Extract the data and convert from V to uV
        # data = raw._data * 1e6
        # sf = raw.info['sfreq']
        # chan = raw.ch_names

        
        # plt.figure(figsize=(10, 5))
        # raw.plot()


        raw.crop(tmax=60.)
        # ica.fit(raw)
        # ica.plot_sources(raw)
        raw.plot(scalings='auto', show=False)
        
        image_path = os.path.join('image', file.filename.replace('.edf', '.png'))

        plt.savefig(image_path)
        buffer = BytesIO()
        plt.savefig(buffer, format='png')
        buffer.seek(0)
        plt.close()
        raw.close()


        img_bytes = buffer.getvalue()
        result = run_model(image_path)
        return img_bytes, result
    except Exception as e:
        abort(500, str(e))
    finally:
        temp_file.close()
        os.unlink(temp_file_path)


def run_model(image_file):
    model_path = 'model'
    
    savedmodel_layer = keras.layers.TFSMLayer(model_path, call_endpoint='serving_default')

    # Create a new model with the TFSMLayer
    new_model = keras.Sequential([
        savedmodel_layer,
        # Add other layers as needed
    ])
    new_model.summary()
    output = []
    images = []
    IMAGE_SIZE = (255, 255)

    
    image = PIL.Image.open(image_file)
    image = image.crop((92, 6, 420, 208))
    image = image.convert('RGB')
    image = image.resize(IMAGE_SIZE)

    images.append(image)

    images = np.array(images, dtype = 'float32')

    output.append((images))

    # app.logger.debug(image)
    predictions = new_model.predict(output[0])
    print(predictions['output_0'][0])
    res = predictions['output_0'][0][0]
    print(res)

    if res < 0.5:
      print("The data is MDD")
      return 'MDD'
    else:
      print("The data is H")
      return "H"

    



@app.route("/")
def read_root():
    return {"Hello": "World"}

@app.route("/upload", methods=["POST"])
def upload_file():

    app.logger.debug(request.files)
    if 'file' not in request.files:
        abort(400, "No file part")
    file = request.files['file']
    app.logger.debug(file.content_type)
    app.logger.debug(file)
    if file.filename == '':
        abort(400, "No selected file")
    if not file.filename.endswith('.edf'):
        abort(400, "Only EDF files are supported.")

    img_bytes, result = process_edf(file)
    image_base64 = base64.b64encode(img_bytes).decode()
    response = jsonify({'result':result,'image':image_base64})
    return response
    # return send_file(BytesIO(img_bytes), mimetype="image/png")

if __name__ == "__main__":
    app.run(debug=True,host="0.0.0.0",port=5001)

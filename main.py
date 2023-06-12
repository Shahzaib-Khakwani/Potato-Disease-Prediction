from fastapi import FastAPI, UploadFile, File
import tensorflow as tf
import numpy as np
from PIL import Image
import io

app = FastAPI()
model = tf.keras.models.load_model("model(2.0).h5")
classes =['Potato___Early_blight', 'Potato___Late_blight', 'Potato___healthy']



@app.get("/")
def index():
    return "Successful" if model != None else "Unsuccessful"


@app.post("/predict")
async def index(file: UploadFile):
    content = await file.read()
    image = Image.open(io.BytesIO(content))
    image = image = image.resize((256,256)).convert("RGB")
    img_array = np.asarray(image)
    img_array = np.expand_dims(img_array, axis=0)
    result =  model.predict(img_array)
    print(result)
    prediction = classes[np.argmax(result)] if type(img_array) == np.ndarray else "Unseuccessful"
    return prediction


@app.post("/uploadfile/")
async def create_upload_file(file: UploadFile  = File(...)):
    return {"filename": file.filename}
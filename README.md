# Depression Detection

### This is a depression detection mobile app made with flutter for frontend and Flask for running the machine learning model, converting edf data to images.

## Setup

### 1. Clone the repo by -

```shell
git clone git@github.com:purveshxd/depression-detection-final-year.git
cd depression-detection-final-year
```

### 2. In the terminal move to the _backend_ folder

```shell
cd backend
```

### 3. Setup a python virtual environment (Refer this [Link](https://www.geeksforgeeks.org/python-virtual-environment/)) for the packages.

### 4. After the virtual environment setup, activate the virtual environment (info give in the same link)

### 5. After the env is running, use the following command to install all the requirements -

```shell
pip install -r /path/to/requirements.txt
```

### 5. In the same directory (_backend_) run the following command -

```shell
python3 main.py
```

> ## Note : This will run the server, also look at the termial for a IP Address other than 127.X.X.1, this other IP-ADD is the one you will enter in the flutter app.

### 6. Also run the flutter app on your android device.

### 7. Now you can enter the ip-address in the app, select the edf data and upload it to server.

## Working

- As the edf data is uploaded to the server, it is converted to a png image.
- This image is then provided to a machine learning model.
- Then the results are being sent back to the flutter app with the image included, tell the user weather the patient is Healthy or Depressed

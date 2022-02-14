from emotion_recognition import EmotionRecognizer
import glob
import pyaudio
import os
import wave
from sys import byteorder
from array import array
from struct import pack
from sklearn.ensemble import GradientBoostingClassifier, BaggingClassifier

from utils import get_best_estimators

import sys

THRESHOLD = 500
CHUNK_SIZE = 1024
FORMAT = pyaudio.paInt16
RATE = 16000

SILENCE = 30

def is_silent(snd_data):
    "Returns 'True' if below the 'silent' threshold"
    return max(snd_data) < THRESHOLD

def normalize(snd_data):
    "Average the volume out"
    MAXIMUM = 16384
    times = float(MAXIMUM)/max(abs(i) for i in snd_data)

    r = array('h')
    for i in snd_data:
        r.append(int(i*times))
    return r

def trim(snd_data):
    "Trim the blank spots at the start and end"
    def _trim(snd_data):
        snd_started = False
        r = array('h')

        for i in snd_data:
            if not snd_started and abs(i)>THRESHOLD:
                snd_started = True
                r.append(i)

            elif snd_started:
                r.append(i)
        return r

    # Trim to the left
    snd_data = _trim(snd_data)

    # Trim to the right
    snd_data.reverse()
    snd_data = _trim(snd_data)
    snd_data.reverse()
    return snd_data

def add_silence(snd_data, seconds):
    "Add silence to the start and end of 'snd_data' of length 'seconds' (float)"
    r = array('h', [0 for i in range(int(seconds*RATE))])
    r.extend(snd_data)
    r.extend([0 for i in range(int(seconds*RATE))])
    return r

def record():
    """
    Record a word or words from the microphone and 
    return the data as an array of signed shorts.

    Normalizes the audio, trims silence from the 
    start and end, and pads with 0.5 seconds of 
    blank sound to make sure VLC et al can play 
    it without getting chopped off.
    """
    p = pyaudio.PyAudio()
    stream = p.open(format=FORMAT, channels=1, rate=RATE,
        input=True, output=True,
        frames_per_buffer=CHUNK_SIZE)

    num_silent = 0
    snd_started = False

    r = array('h')

    while 1:
        # little endian, signed short
        snd_data = array('h', stream.read(CHUNK_SIZE))
        if byteorder == 'big':
            snd_data.byteswap()
        r.extend(snd_data)

        silent = is_silent(snd_data)

        if silent and snd_started:
            num_silent += 1
        elif not silent and not snd_started:
            snd_started = True

        if snd_started and num_silent > SILENCE:
            break

    sample_width = p.get_sample_size(FORMAT)
    stream.stop_stream()
    stream.close()
    p.terminate()

    r = normalize(r)
    r = trim(r)
    r = add_silence(r, 0.5)
    return sample_width, r

def record_to_file(path):
    "Records from the microphone and outputs the resulting data to 'path'"
    sample_width, data = record()
    data = pack('<' + ('h'*len(data)), *data)

    wf = wave.open(path, 'wb')
    wf.setnchannels(1)
    wf.setsampwidth(sample_width)
    wf.setframerate(RATE)
    wf.writeframes(data)
    wf.close()


def get_estimators_name(estimators):
    result = [ '"{}"'.format(estimator.__class__.__name__) for estimator, _, _ in estimators ]
    return ','.join(result), {estimator_name.strip('"'): estimator for estimator_name, (estimator, _, _) in zip(result, estimators)}



def main(arg1):
    estimators = get_best_estimators(True)
    estimators_str, estimator_dict = get_estimators_name(estimators)
    # import argparse
    # parser = argparse.ArgumentParser(description="""
    #                                 Testing emotion recognition system using your voice, 
    #                                 please consider changing the model and/or parameters as you wish.
    #                                 """)

    # parser.add_argument("-f", "--file", help=
    # """
    # file wav to analyze"
    # """, required=True)


    # Parse the arguments passed
    #args = parser.parse_args()


    emotions = "sad,neutral,happy,angry,fear"
    model ="BaggingClassifier"

    features = ["mfcc", "chroma", "mel"]
    detector = EmotionRecognizer(estimator_dict[model], emotions=emotions.split(","), features=features, verbose=0)
    detector.train()

    detector.test_score()*100
    
    print(detector.predict_proba(arg1))
    

    #print("Please talk")

    #for file in glob.glob("Emo/*.wav"):
        #basename = os.path.basename(file)
        # path_basename = "/Users/marco/Downloads/emotion-recognition-using-speech-master/"+file 
        # path_output = "/Users/marco/Downloads/emotion-recognition-using-speech-master/data/custom-train/"+basename 
        #plit_string = basename.split(".", 1)

    #filename = "test.wav"
    #record_to_file(filename)
        #print(basename)
        #print(detector.predict_proba(file))
        #print()
    #result = detector.predict_proba(file)

    # print("Audio calmo:")
    #print(detector.predict_proba("data/patient/OAF_bar_angry.wav"))
    # print("Audio angry:")
    # print(detector.predict_proba("data/patient/14_01_01_01_dogs-sitting_angry.wav"))
    # print(detector.predict_proba("data/patient/gio-m3-l4_happy.wav"))
    # print(detector.predict_proba("data/patient/gio-m3-n1_happy.wav"))

    #print(result)

if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
    
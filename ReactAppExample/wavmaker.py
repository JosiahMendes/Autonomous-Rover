from scipy.io.wavfile import write
import numpy as np
lines = np.loadtxt("test0.txt", comments="#", delimiter=",", unpack=False)

import io
import soundfile as sf

data, samplerate = sf.read(io.BytesIO(lines))
write('test.wav',samplerate,data)

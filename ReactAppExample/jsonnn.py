import argparse
import numpy as np
import shlex
import subprocess
import sys
import wave
import json
import os

from deepspeech import Model, version

def words_from_candidate_transcript(metadata):
    word = ""
    word_list = []
    word_start_time = 0
    # Loop through each character
    k = 0
    for i, token in enumerate(metadata.tokens):
        # Append character to word if it's not a space
        if token.text != " ":
            if len(word) == 0:
                # Log the start time of the new word
                word_start_time = token.start_time
            
            word = word + token.text
        # Word boundary is either a space or the last character in the array
        if token.text == " " or i == len(metadata.tokens) - 1:
            word_duration = token.start_time - word_start_time
            
            if word_duration < 0:
                word_duration = 0
            
            each_word = dict()
            each_word["id"] = k
            each_word["word"] = word
            each_word["begin"] = round(word_start_time, 4)
            each_word["dur"] = round(word_duration, 4)
            k = k+1
            word_list.append(each_word)
            # Reset
            word = ""
            word_start_time = 0

    return word_list

def metadata_json_output(metadata):
    json_result = dict()
    json_result = words_from_candidate_transcript(metadata.transcripts[0])
    return json.dumps(json_result, indent=2)
def main():
    parser = argparse.ArgumentParser(description='Running DeepSpeech inference.')
    parser.add_argument('--audio', required=True,
                        help='Path to the audio file to run (WAV format)')
    parser.add_argument('--beam_width', type=int,
                        help='Beam width for the CTC decoder')
    parser.add_argument('--lm_alpha', type=float,
                        help='Language model weight (lm_alpha). If not specified, use default from the scorer package.')
    parser.add_argument('--lm_beta', type=float,
                        help='Word insertion bonus (lm_beta). If not specified, use default from the scorer package.')
    parser.add_argument('--extended', required=False, action='store_true',
                        help='Output string from extended metadata')
    parser.add_argument('--json', required=False, action='store_true',
                        help='Output json from metadata with timestamp of each word')
    parser.add_argument('--candidate_transcripts', type=int, default=3,
                        help='Number of candidate transcripts to include in JSON output')
    args = parser.parse_args()

   
    
    # sphinx-doc: python_ref_model_start
    ds = Model('output_graph.pbmm')
    # sphinx-doc: python_ref_model_stop
    
   

    ds.enableExternalScorer('kenlm.scorer')


    fin = wave.open(args.audio, 'rb')
    fs_orig = fin.getframerate()
    
    audio = np.frombuffer(fin.readframes(fin.getnframes()), np.int16)

    audio_length = fin.getnframes() * (1/fs_orig)
    fin.close()

    # sphinx-doc: python_ref_inference_start
   
    json_data = metadata_json_output(ds.sttWithMetadata(audio, 1))
    json_name = 'json/' +  os.path.splitext(args.audio)[0]+'.json'
    json_file = open(json_name, 'w+')
    json_file.write(json_data)
    json_file.close()
    print("succeed")
    
  

if __name__ == '__main__':
    main()

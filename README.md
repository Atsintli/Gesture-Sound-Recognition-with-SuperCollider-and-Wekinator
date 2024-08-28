# Gesture Sound Recognition with SuperCollider and Wekinator

This repository contains SuperCollider code for a system that captures sound features from audio files and real-time microphone input, processes them, and sends the extracted features to Wekinator for training and gesture sound recognition.

## Overview

The SuperCollider code in this project is designed to:

- Load and process audio files.
- Extract audio features using various feature extraction techniques.
- Send the processed features to Wekinator via OSC (Open Sound Control) for real-time gesture sound recognition and training.
- Integrate with a microphone to record live audio and process it on the fly.

The system is built to train Wekinator to recognize different classes of sounds based on extracted features, enabling interaction with sound gestures.

## Requirements

- **SuperCollider**: Ensure that you have SuperCollider installed. You can download it from [here](https://supercollider.github.io/).
- **Wekinator**: For gesture recognition, you'll need Wekinator. You can download it from [here](http://www.wekinator.org/).
- **SCMIR**: The project uses `SCMIR` for feature extraction. You can install it by running `Quarks.install("SCMIR")` in SuperCollider.
- **OSC communication**: Wekinator and SuperCollider communicate using OSC. Ensure both are set up to listen and send OSC messages on the correct ports.

## Setup

1. **Audio Buffer Setup**: The system loads audio files from predefined directories, processes them, and assigns them to different categories.

2. **Server Configuration**: SuperCollider server options are configured with increased memory to handle the processing requirements. This is done in the following block of code:

    ```supercollider
    (
    o = Server.local.options;
    Server.local.options.memSize = 2.pow(21);
    Server.internal.options.memSize = 2.pow(21);
    s.reboot;
    )
    ```

3. **Loading Necessary Scripts**: The system loads several scripts required for feature extraction, audio processing, and OSC communication:

    ```supercollider
    (
    ~currentPath = thisProcess.nowExecutingPath.dirname;
    (~currentPath++"/ventanizar.scd").load;
    (~currentPath++"/rec-loop.scd").load;
    (~currentPath++"/stringify.scd").load;
    (~currentPath++"/get-audio-features.scd").load;
    (~currentPath++"/get_audios_3.scd").load;
    )
    ```

4. **Audio File Categorization**: Audio files are loaded into different categories such as `periodico`, `complejo`, and `fijo`. These categories are represented as arrays of buffers:

    ```supercollider
    (
    ~periodico = Array.new;
    ~folder = PathName.new("/path/to/your/periodico/files");
    (
    ~folder.entries.do({
        arg path;
        ~periodico = ~periodico.add(Buffer.read(s, path.fullPath));
    });
    );
    )
    ```

## Synth Definitions

Several synths are defined for playing back the audio files with various effects. Each synth can be triggered based on the features extracted from the audio input:

- `\caotico`
- `\complejo`
- `\fijo`
- `\periodico`

These synths utilize SuperCollider's `PlayBuf` and `EnvGen` UGens to control playback and apply envelope shaping to the audio.

```supercollider
SynthDef(\periodico, {
    arg amp=1, out=0, buf, rate=1, loop=0, start;
    var sig, env;
    sig = PlayBuf.ar(2, buf, rate, 1, start, loop, doneAction: 2);
    env = EnvGen.kr(Env.new([0, 0.1, 0.21, 0 ], [2, 20, 2]));
    sig = sig * env;
    Out.ar(out, GVerb.ar(sig, 30, 0.01));
}).add;
```

## Feature Extraction and OSC Communication

### Feature Extraction
The system uses the `SCMIR` library to extract various features such as `Chromagram`, `SpecPcile`, `SpecFlatness`, and `OnsetStatistics` from audio files. The features are processed in segments (windows) of audio data.

```supercollider
~getAudioFeatures = {|sources, classNames = ([\unknown]), features, ventanizar, ventaneo|
    var scmirs = sources.inject(
        Dictionary.new,
        {|dict, array, index|
            var numFeatures;
            var dataArr = array.collect{|filename|
                var file = SCMIRAudioFile(filename, features);
                file.extractFeatures();
                file.gatherFeaturesBySegments([0.0]);
                file.featuredata.asArray;
            };
            dict.put(classNames[index], dataArr.collect({|data| ventanizar.(numFeatures, data)}));
            dict;
    });
    scmirs;
};
```

### Sending Data to Wekinator
Once features are extracted, they are flattened and sent to Wekinator over OSC for training and recognition.

```supercollider
~client = NetAddr("127.0.0.1", 5005); // Wekinator's listening address

Task({
    inf.do({
        ~client.sendMsg("/features", *~data);
        0.2.wait;
    });
}).play;
```

## Running the System

To run the system:

1. Start SuperCollider and evaluate the setup scripts to configure the server and load the necessary files.
2. Begin feature extraction and OSC communication with Wekinator by running the appropriate tasks.
3. Train Wekinator using the extracted features to recognize different sound gestures.
4. Once trained, Wekinator will send back the recognized gestures, which can be mapped to trigger specific synths in SuperCollider.

## Example Workflow

1. Load audio data into buffers.
2. Extract features from the audio.
3. Send features to Wekinator for training.
4. Based on the recognized gestures, trigger different sound events in SuperCollider.

## License

This project is licensed under the MIT License. See the `LICENSE` file for more details.

## Acknowledgments

- This project uses `SCMIR` for feature extraction in SuperCollider.
- OSC communication is handled to interface with Wekinator for real-time sound gesture recognition.

---

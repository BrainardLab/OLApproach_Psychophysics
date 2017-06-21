function  [stopSound, startSound, hintSound] = generateSounds()
    fs = 20000; durSecs = 0.1; 
    t = linspace(0, durSecs, durSecs*fs);
    
    stopSound.y = sin(440*2*pi*t);
    stopSound.fs = fs;
    
    startSound.y = sin(880*2*pi*t);
    startSound.fs = fs;
    
    durSecs = 0.01;
    t = linspace(0, durSecs, durSecs*fs);
    hintSound.y = sin(880*2*pi*t);
    hintSound.fs = fs;
end